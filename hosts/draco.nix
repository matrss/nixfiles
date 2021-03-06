{ lib, pkgs, modulesPath, hosts, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ../users/root ];

  # Use grub2.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Kernel modules to include.
  boot.initrd.availableKernelModules =
    [ "ata_piix" "virtio_pci" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  # Filesystems to be mounted.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/50f6ff94-9543-43bb-83a8-897a0f3911c9";
    fsType = "ext4";
  };

  swapDevices = [ ];

  # # Don't swap as much; should be better for the SSD.
  # boot.kernel.sysctl."vm.swappiness" = 1;

  # Enable ssh server.
  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
  };

  # Ban attackers.
  services.fail2ban = {
    enable = true;
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
  };

  # # Set initial root password to empty.
  # users.users.root.initialHashedPassword = "";

  # # SSH key.
  # users.users.root.openssh.authorizedKeys.keys = [
  #   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF5mtCDOZCqK5JhMN+UZLOd8ua2rk9IOyuR+79q+szgW+PpwG0FFkQWoy31YhL0oTEe34txf9nling8XAgv6iYwJ6SV6Y5mw17NWlLiqar5mVrk7u2VG8VOeaM1aQYZVbHTgxShxRVDZinda22EAnYnzLrAqqQvb3OR2mpOgt/5KxdtR1+aj63TAVgICqOCW7/POTL4Lul3dXLoLf2OqtUwC99OasOcWUmzCrOAuh/egSXQzz8RZ4/vmLvzdFI67DiBtAI0VnADHQmhw98Z6zrdLOdoH12XqlYLlf+MUVxjRQAZz1EZ1rnaI2rJGQEifK84cMUQ2/lI0GDxeIOMOT8eUJFAV7B0dE7Pxy8Ulw3DNHYZqk0O7al9qiQPcTjht4Ae7NLyX43z2NlWf9ISkbqENqpD/py6pmf3D5qt/gN6EI0daZtpP81gS2iFVVRhIymeSQNxD54Yugw62Mcq9nurYZZPPZWHe0qakqnJfBRcOGN6pStboyOaHAp5q2Wn1HcdM7LOViVNRXsfnSGhiSJACcXwKA0gbq2o+JMqzq3u0OiMxb5ZFqyDt6lPy8vKvsKw0J89JHMLMg5s4A/DDU7YFfICpGZPLW+mhz789jMvOo9SYHFM7KhK9HXxKNvGpjS8OK736z8FXzOsHqcbNpjXXIccruIC1RI+QlYf8jLIw== cardno:000609614342"
  # ];

  environment.systemPackages = with pkgs; [ vim ];
  # services.xserver.desktopManager.plasma5.enable = true;

  networking.interfaces."tinc.mesh".ipv4.addresses = [{
    address = hosts.draco.ip.tinc;
    prefixLength = 24;
  }];
  networking.firewall.allowedUDPPorts = [ 655 ];
  networking.firewall.allowedTCPPorts = [ 655 ];

  services.tinc.networks.mesh = {
    name = "draco";
    rsaPrivateKeyFile = ../secrets/hosts/draco/tinc/rsa_key.priv;
    ed25519PrivateKeyFile = ../secrets/hosts/draco/tinc/ed25519_key.priv;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
