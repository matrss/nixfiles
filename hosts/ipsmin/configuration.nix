{ pkgs, ... }:

{
  imports = [
    ../../profiles/users/matrss
    ../../profiles/users/root
    ../../profiles/graphical/gnome.nix
  ];

  networking.hostName = "ipsmin";
  networking.domain = "m.matrss.xyz";

  networking.interfaces.enp0s31f6.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 100;
  boot.loader.efi.canTouchEfiVariables = false;

  # Decrypt root and swap at boot.
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-partlabel/luks";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # Filesystems to be mounted.
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=8G" "mode=755" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/77E6-E940";
    fsType = "vfat";
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/ff54ccee-9cdb-4347-8434-26ba318e01dc";
    fsType = "ext4";
    # Supposedly better for the SSD.
    options = [ "noatime" "nodiratime" "discard" ];
    neededForBoot = true;
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/home"
      "/nix"
      "/root"
      "/var/lib/bluetooth"
      "/var/lib/colord"
      "/var/lib/cups"
      "/var/lib/systemd/backlight"
      "/var/lib/systemd/coredump"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  # Swap partitions to use.
  swapDevices =
    [{ device = "/dev/disk/by-uuid/c68db7c4-cd2d-407a-beae-7025344975f6"; }];

  # Don't swap as much; should be better for the SSD.
  boot.kernel.sysctl."vm.swappiness" = 1;

  # Enable ssh server
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    hplip
    samsung-unified-linux-driver_1_00_37
  ];

  # Auto discovery.
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  # Enable pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.enableRedistributableFirmware = true;

  # Enable bluetooth for pen
  hardware.bluetooth.enable = true;

  # Enable IIO sensors
  hardware.sensor.iio.enable = true;

  # Enable docker daemon
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.singularity.enable = true;
  environment.systemPackages = with pkgs; [
    docker-compose
    hunspell
    hunspellDicts.en-us
    hunspellDicts.en-us-large
    hunspellDicts.de-de
  ];

  # Enable adb
  programs.adb.enable = true;

  # Enable scanner support
  hardware.sane.enable = true;
  hardware.sane.extraBackends = with pkgs; [
    sane-airscan
    hplip
  ];

  nix.daemonCPUSchedPolicy = "idle";

  services.ananicy.enable = true;
  # services.ananicy.package = pkgs.ananicy-cpp;

  users.mutableUsers = false;

  sops.defaultSopsFile = ../../secrets/ipsmin/secrets.yaml;
  sops.age.keyFile = "/persist/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?
}
