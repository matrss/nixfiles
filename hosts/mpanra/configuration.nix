{ ... }:

{
  imports = [
    ../../profiles/users/root
    ./acme.nix
    # ./bazarr.nix
    ./cloudflare-dyndns.nix
    # ./fail2ban.nix
    # ./home-assistant.nix
    # ./jellyfin.nix
    # ./kanidm.nix
    # ./nextcloud.nix
    ./nginx.nix
    # ./nix-serve.nix
    ./paperless.nix
    # ./postgresql.nix
    # ./radarr.nix
    # ./sonarr.nix
    # ./tiddlywiki.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "mpanra";
  networking.domain = "m.0px.xyz";
  networking.tempAddresses = "disabled";

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  sops.defaultSopsFile = ../../secrets/mpanra/secrets.yaml;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
