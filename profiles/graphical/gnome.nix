{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  hardware.pulseaudio.enable = false;

  environment.variables.MOZ_ENABLE_WAYLAND = "1";

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    noto-fonts

    firefox
    thunderbird
    vlc

    barrier

    anki
    zoom-us
    zotero
    spotify
    libreoffice
    xournalpp
    discord
    bitwarden
    gimp
    nextcloud-client
    teams
    krita

    gnome.gnome-tweaks
  ];
}