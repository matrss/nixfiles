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

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  networking.firewall = let
    kdeconnectPorts = {
      from = 1714;
      to = 1764;
    };
  in {
    allowedTCPPortRanges = [ kdeconnectPorts ];
    allowedUDPPortRanges = [ kdeconnectPorts ];
  };

  environment.systemPackages = with pkgs; [
    firefox
    plasma-browser-integration
    thunderbird
    vlc

    anki
    zoom-us
    zotero
    spotify
    libreoffice
    xournalpp
    discord
    qtpass

    # KDE/Plasma apps
    syncthingtray
    krunner-pass
    okular
    ark
    gwenview
    skanlite
    kdeconnect
  ];

  programs.steam.enable = true;
}
