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
    htop
    tree
    opensc
    doas
  ];

  # Enable flakes support.
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Needed Syncthing errors relating to too many fs watchers.
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  services.resolved.domains = [ "local" ];

  services.udev.packages = with pkgs; [ libu2f-host yubikey-personalization ];
}
