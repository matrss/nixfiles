{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.runUsingSystemd = true;

  programs.kdeconnect.enable = true;
  networking.networkmanager.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";
  };

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    vlc

    anki
    zoom-us
    zotero
    spotify
    libreoffice
    xournalpp
    discord
    bitwarden
    solaar
    gimp
    nextcloud-client

    teams

    # KDE/Plasma apps
    syncthingtray
    skanlite
    krita

    ark
  ] ++ builtins.filter lib.isDerivation (builtins.attrValues plasma5Packages.kdeFrameworks);
  # ++ builtins.filter lib.isDerivation (builtins.attrValues plasma5Packages.kdeGear);
  # ++ builtins.filter lib.isDerivation (builtins.attrValues plasma5Packages.plasma5);
}
