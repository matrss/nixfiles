{ lib, config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    neovim
    gnumake
    htop
    tree
    opensc
  ];

  nix = {
    # Enable flakes support.
    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = ${pkgs.writeText "flake-registry.json" (builtins.toJSON { flakes = []; version = 2; })}
    '';
    # gc.automatic = true;
    optimise.automatic = true;
    settings.trusted-users = [ "@wheel" ];
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

  security.sudo.execWheelOnly = true;
}
