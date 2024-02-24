{ config, ... }:

let
  flake = "github:matrss/nixfiles/main";
in
{
  system.autoUpgrade = {
    enable = true;
    flake = "${flake}#${config.networking.fqdn}";
    flags = [ "--accept-flake-config" "--refresh" ];
  };
}
