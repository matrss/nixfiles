{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.autorotate;

in {
  options = {
    services.autorotate = {
      enable = mkEnableOption "autorotate script for sway";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.autorotate = {
      Unit = {
        Description = "screen rotation script";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = { ExecStart = "${pkgs.autorotate}/bin/autorotate"; };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
