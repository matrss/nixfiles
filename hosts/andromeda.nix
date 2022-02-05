{ lib, config, pkgs, hosts, ... }:

{
  imports = [
    ../users/matrss
    ../users/root
    ../profiles/graphical/gnome.nix
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

  # Power management
  # TODO: possibly undervolt
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     TLP_ENABLE = 1;
  #     TLP_DEFAULT_MODE = "AC";
  #     CPU_MIN_PERF_ON_AC = 0;
  #     CPU_MAX_PERF_ON_AC = 100;
  #     CPU_MIN_PERF_ON_BAT = 0;
  #     CPU_MAX_PERF_ON_BAT = 50;
  #     DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
  #     DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
  #     DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
  #     DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";
  #     DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT = "";
  #     DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT = "";
  #     USB_BLACKLIST_PHONE = 1;
  #   };
  # };

  # Microcode update
  hardware.cpu.intel.updateMicrocode = true;

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
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Enable opengl for wayland.
  hardware.opengl.enable = true;

  # Enable bluetooth for pen
  hardware.bluetooth.enable = true;

  # Enable IIO sensors
  hardware.sensor.iio.enable = true;

  # Enable docker daemon
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.singularity.enable = true;
  environment.systemPackages = with pkgs; [ docker-compose virt-manager ];

  # virtualisation.podman.enable = true;

  # Enable adb
  programs.adb.enable = true;

  # Enable scanner support
  hardware.sane.enable = true;
  hardware.sane.extraBackends = with pkgs; [
    sane-airscan
    hplip
    # samsung-unified-linux-driver_1_00_37
  ];

  # Enable ara as substituter
  nix.binaryCaches = [ "ssh://ara-binary-cache" ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  services.xserver.wacom.enable = lib.mkDefault config.services.xserver.enable;

  sops.defaultSopsFile = ../secrets/andromeda/secrets.yaml;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?
}
