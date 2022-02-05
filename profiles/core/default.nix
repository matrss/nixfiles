{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    vim
    gnumake
    htop
    tree
    opensc
    doas
  ];

  # Enable flakes support.
  nix = {
    package = pkgs.nixFlakes;
    generateRegistryFromInputs = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # gc.automatic = true;
    optimise.automatic = true;
    trustedUsers = [ "@wheel" ];
    binaryCachePublicKeys = [ "ara.matrss.de-1:ZQzhLCE7akrXB8TvU7Nts3tn7oDujt/GMXQPo5gGYsU=" ];
  };

  # Just very convenient.
  programs.command-not-found.enable = true;

  # Put /tmp on tmpfs
  boot.tmpOnTmpfs = true;

  # Needed Syncthing errors relating to too many fs watchers.
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  services.resolved.domains = [ "local" ];

  services.udev.packages = with pkgs; [ libu2f-host yubikey-personalization ];

  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;

  sops.secrets.root-ssh-key = { };
}
