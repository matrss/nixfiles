{ config, pkgs, ... }:

let
  flake = "github:matrss/nixfiles/main";
in
{
  system.autoUpgrade = {
    enable = true;
    flake = "${flake}#${config.networking.fqdn}";
    flags = [ "--accept-flake-config" "--refresh" ];
  };

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellApplication {
      name = "system-upgrade";
      runtimeInputs = [ pkgs.nixos-rebuild ];
      text = ''
        nixos-rebuild switch --accept-flake-config --refresh --flake '${flake}#${config.networking.fqdn}'
      '';
    })
  ];
}
