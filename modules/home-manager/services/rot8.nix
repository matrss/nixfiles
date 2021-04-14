{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.rot8;

in
{
  options = {
    services.rot8 = {
      enable = mkEnableOption "the rot8 screen rotation daemon";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.rot8 ];

    systemd.user.services.rot8 = {
      Unit = {
        Description = "screen rotation daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = { ExecStart = "${pkgs.rot8}/bin/rot8"; };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
