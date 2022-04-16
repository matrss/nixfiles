{ pkgs, config, ... }:

{
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_14;
}
