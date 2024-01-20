{
  imports = [
    ../../profiles/users/root
    ./acme.nix
    ./nginx.nix
    ./dns-over-tls.nix
    ./smtp2paperless.nix
    ./uptime-kuma.nix
  ];

  zramSwap.enable = true;
  networking.hostName = "hazuno";
  networking.domain = "m.0px.xyz";
  networking.tempAddresses = "disabled";
  services.openssh.enable = true;

  # Filesystems to be mounted.
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=512M" "mode=755" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8DEA-BE31";
    fsType = "vfat";
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "/dev/sda1";
    fsType = "ext4";
    neededForBoot = true;
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/home"
      "/nix"
      "/root"
      "/var/lib"
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

  sops.defaultSopsFile = ../../secrets/hazuno/secrets.yaml;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
