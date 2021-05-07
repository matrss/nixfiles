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

  networking.firewall =
    let
      kdeconnectPorts = {
        from = 1714;
        to = 1764;
      };
    in
    {
      allowedTCPPortRanges = [ kdeconnectPorts ];
      allowedUDPPortRanges = [ kdeconnectPorts ];
    };
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
    qtpass
    solaar
    gimp

    # KDE/Plasma apps
    syncthingtray
    krunner-pass
    okular
    ark
    gwenview
    skanlite
    krita
    kdeconnect
  ];

  programs.steam.enable = true;
}
