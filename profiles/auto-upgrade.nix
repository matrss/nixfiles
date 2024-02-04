{ config, ... }:

{
  system.autoUpgrade = {
    enable = true;
    flake = "github:matrss/nixfiles/main#${config.networking.fqdn}";
    flags = [ "--accept-flake-config" "--refresh" ];
  };
}
