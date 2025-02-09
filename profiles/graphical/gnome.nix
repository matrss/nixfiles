{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.xserver.wacom.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  hardware.pulseaudio.enable = false;

  environment.variables.MOZ_ENABLE_WAYLAND = "1";

  programs.steam.enable = true;

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  qt.style = "adwaita-dark";

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-boxes
    gnome-terminal
    dconf-editor
    gnome-console
  ];
}
