{ lib, pkgs, config, ... }:

let
  hosts = {
    # Homeserver
    ara.ip.lan = "192.168.178.254";

    # FRITZ!Box
    router.ip.lan = "192.168.178.1";
  };
in
{
  imports = [
    ../users/root
    ../users/matrss-ara
    ../gitlab-runner.nix
    ../traefik.nix
    ../oci-container/authelia
    ../nixos-container/jellyfin.nix
    ../nixos-container/nextcloud.nix
    ../nixos-container/sonarr.nix
    ../nixos-container/radarr.nix
    # ../nixos-container/bazarr.nix
  ];

  networking.hostName = "ara";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 100;
  boot.loader.efi.canTouchEfiVariables = false;

  # Kernel modules to include.
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "e1000e"
    "igb"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Decrypt lvm at boot.
  boot.initrd.luks = {
    devices = {
      crypt-pv = {
        device = "/dev/disk/by-partlabel/luks";
        preLVM = true;
        allowDiscards = true;
      };

      VGG2KJ1G = {
        device = "/dev/disk/by-id/ata-HGST_HUS728T8TALE6L4_VGG2KJ1G";
        preLVM = true;
      };

      VGJKAE1G = {
        device = "/dev/disk/by-id/ata-HGST_HUS728T8TALE6L4_VGJKAE1G";
        preLVM = true;
      };
    };
    reusePassphrases = true;
  };

  # Early ssh so that the disk can be decrypted.
  sops.secrets.initrd-ssh-key = { };
  boot.kernelParams = [
    "ip=${hosts.ara.ip.lan}::${hosts.router.ip.lan}:255.255.255.0::enp0s25:off"
  ];
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    hostKeys = [ config.sops.secrets.initrd-ssh-key.path ];
  };

  # Don't swap as much; should be better for the SSD.
  boot.kernel.sysctl."vm.swappiness" = 1;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  networking.interfaces.enp3s0.useDHCP = false;
  networking.interfaces.enp0s25.ipv4.addresses = [{
    address = hosts.ara.ip.lan;
    prefixLength = 24;
  }];

  networking.defaultGateway = hosts.router.ip.lan;
  networking.nameservers = [ hosts.router.ip.lan ];

  # Filesystems to be mounted.
  fileSystems."/" = {
    device = "/dev/vg/root";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/esp";
    fsType = "vfat";
  };

  fileSystems."/data-root" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/" ];
  };

  fileSystems."/home" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/home" ];
  };

  fileSystems."/srv/media" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/media" ];
  };

  fileSystems."/srv/data" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/data" ];
  };

  fileSystems."/volumes" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/volumes" ];
  };

  swapDevices = [ ];

  # Enable ssh server.
  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    # Required for fail2ban
    logLevel = "VERBOSE";
  };

  # Ban attackers.
  services.fail2ban = {
    enable = true;
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
  };

  # Auto discovery.
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.addresses = true;

  # Default sops file for secrets.
  sops.defaultSopsFile = ../../secrets/ara/secrets.yaml;

  environment.systemPackages = with pkgs; [
    vim
    btrfs-progs
    smartmontools
    mkvtoolnix
    mediainfo
    ffmpeg
  ];

  # Enable dynamic dns updating.
  sops.secrets.ddclient-config = { };
  services.ddclient = {
    enable = true;
    configFile = config.sops.secrets.ddclient-config.path;
  };

  # Serve nix store via ssh
  nix.sshServe = {
    enable = true;
    write = true;
    keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWXOgpAWXNPVnq9pw3qmtUPl+yynT9GCmG0JxWPsJt4 gitlab-ci" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGFjDIcea7ScFIv87nevx9ShfPGEoWedQ6JNRoqVPLg root@andromeda" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeFg7nYVjzT1v6umYLpJaFfvvHqyxiixbWOX7EaOn6Y root@ara" ];
  };

  nix.settings.trusted-users = [ "nix-ssh" ];

  # services.f2b-miner = {
  #   enable = true;
  #   logFile = "/home/matrss/public/data/f2b-bans.csv";
  #   user = "matrss";
  #   group = "users";
  # };

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "overlay2";

  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-+" ];
  networking.nat.externalInterface = "enp0s25";

  # virtualisation.podman.enable = true;
  # virtualisation.oci-containers.backend = "podman";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
