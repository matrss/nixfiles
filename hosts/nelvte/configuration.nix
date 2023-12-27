{ pkgs, ... }:

{
  imports = [
    ../../profiles/users/root
    ./cloudflare-dyndns.nix
    ./fail2ban.nix
    ./mpanra
    ./restic.nix
  ];

  networking.hostName = "nelvte";
  networking.domain = "m.0px.xyz";
  networking.tempAddresses = "disabled";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 100;
  boot.loader.efi.canTouchEfiVariables = false;

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

      WCC7K2PT4SFH = {
        device = "/dev/disk/by-id/ata-WDC_WD40EFRX-68N32N0_WD-WCC7K2PT4SFH";
        preLVM = true;
      };
    };
    reusePassphrases = true;
  };

  networking.interfaces.enp3s0.useDHCP = false;

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

  fileSystems."/data" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/" ];
  };

  fileSystems."/nix" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/nix" "noatime" ];
  };

  fileSystems."/var/lib" = {
    device = "LABEL=data";
    fsType = "btrfs";
    options = [ "defaults" "autodefrag" "compress=zstd" "subvol=/varlib" ];
  };

  fileSystems."/backup" = {
    device = "LABEL=backup";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  swapDevices = [ ];

  # Enable ssh server.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      # Required for fail2ban
      LogLevel = "VERBOSE";
    };
  };

  # Auto discovery.
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.addresses = true;

  # Default sops file for secrets.
  sops.defaultSopsFile = ../../secrets/nelvte/secrets.yaml;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    smartmontools
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
