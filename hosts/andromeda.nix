{ lib, pkgs, hosts, ... }:

{
  imports = [
    ../users/matrss
    ../users/matrss2
    ../users/root
    ../profiles/wifi.nix
    ../profiles/graphical/plasma.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules to include.
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Decrypt root and swap at boot.
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-partlabel/luks";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Filesystems to be mounted.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ff54ccee-9cdb-4347-8434-26ba318e01dc";
    fsType = "ext4";
    # Supposedly better for the SSD.
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/77E6-E940";
    fsType = "vfat";
  };

  # Swap partitions to use.
  swapDevices =
    [{ device = "/dev/disk/by-uuid/c68db7c4-cd2d-407a-beae-7025344975f6"; }];

  # Don't swap as much; should be better for the SSD.
  boot.kernel.sysctl."vm.swappiness" = 1;

  # CPU governor.
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

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

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable opengl for wayland.
  hardware.opengl.enable = true;

  # Enable bluetooth for pen
  hardware.bluetooth.enable = true;

  # Enable IIO sensors
  hardware.sensor.iio.enable = true;

  # Enable docker daemon
  virtualisation.docker.enable = true;
  # programs.singularity.enable = true;
  environment.systemPackages = with pkgs; [ docker-compose ];

  virtualisation.podman.enable = true;

  # Enable adb
  programs.adb.enable = true;

  # Enable scanner support
  hardware.sane.enable = true;
  hardware.sane.extraBackends = with pkgs; [
    sane-airscan
    hplip
    # samsung-unified-linux-driver_1_00_37
  ];

  networking.interfaces."tinc.mesh".ipv4.addresses = [{
    address = hosts.andromeda.ip.tinc;
    prefixLength = 24;
  }];
  networking.firewall.allowedUDPPorts = [ 655 ];
  networking.firewall.allowedTCPPorts = [ 655 3179 ];

  networking.firewall.enable = true;

  services.tinc.networks.mesh = {
    name = "andromeda";
    # settings.PrivateKeyFile = "../secrets/hosts/andromeda/tinc/rsa_key.priv";
    # settings.Ed25519PrivateKeyFile = "/home/matrss/nix-config/secrets/hosts/andromeda/tinc/ed25519_key.priv";
    rsaPrivateKeyFile = builtins.toFile "rsa.priv"
      (builtins.readFile ../secrets/hosts/andromeda/tinc/rsa_key.priv);
    ed25519PrivateKeyFile = builtins.toFile "ed25519.priv"
      (builtins.readFile ../secrets/hosts/andromeda/tinc/ed25519_key.priv);
    extraConfig = ''
      ConnectTo = draco
    '';
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?
}
