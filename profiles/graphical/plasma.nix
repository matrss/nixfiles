{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  # services.xserver.wacom.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sessionPackages = [
    (pkgs.plasma-workspace.overrideAttrs
      (old: { passthru.providedSessions = [ "plasmawayland" ]; }))
  ];
  services.xserver.desktopManager.plasma5.enable = true;

  # This is set by default by enabling services.xserver.desktopManager.plasma5
  # nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  programs.kdeconnect.enable = true;
  networking.networkmanager.enable = true;

  # Enable solaar udev rule for logitech devices
  services.udev.packages = [ pkgs.solaar ];

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
    nixpkgs.discord
    bitwarden
    solaar
    gimp
    nextcloud-client

    teams

    # KDE/Plasma apps
    plasma5Packages.thirdParty.plasma-applet-virtual-desktop-bar
    syncthingtray
    skanlite
    krita
  ] ++ builtins.filter lib.isDerivation (builtins.attrValues plasma5Packages.kdeGear)
    ++ builtins.filter lib.isDerivation (builtins.attrValues plasma5Packages.kdeFrameworks);
    # ++ builtins.filter lib.isDerivation (builtins.attrValues plasma5Packages.plasma5);

  programs.steam.enable = true;
}
