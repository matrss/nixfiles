{ config, ... }:

let
  flake = "github:matrss/nixfiles/main";
in
{
  system.autoUpgrade = {
    enable = true;
    flake = "${flake}#${builtins.replaceStrings ["."] ["_"] config.networking.fqdn}";
    flags = [ "--accept-flake-config" "--refresh" ];
  };
}
