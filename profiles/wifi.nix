{ pkgs, ... }:

{
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;

  # networking.wireless.networks = import ../secrets/wifi-networks.nix;

  networking.networkmanager.enable = true;
  # networking.networkmanager.packages = [ pkgs.networkmanager-ssh ];
}
