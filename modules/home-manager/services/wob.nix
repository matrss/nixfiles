{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.wob;

in {
  options = {
    services.wob = {
      enable = mkEnableOption "Whether to enable wob.";

      package = mkOption {
        type = types.package;
        default = pkgs.wob;
        defaultText = "pkgs.wob";
        description = ''
          wob derivation to use.
        '';
      };

      max = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Maximum value, corresponding to a full bar.
        '';
      };

      timeout = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Hide wob after this timeout, in milliseconds.
        '';
      };

      anchors = mkOption {
        type =
          types.listOf (types.enum [ "top" "left" "right" "bottom" "center" ]);
        default = [ ];
        description = ''
          Specifies the location of the bar. Multiple values are used to specify,
          for example, the bottom right corner.
        '';
      };

      margin = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Anchor margin in pixels.
        '';
      };

      offset = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Border offset in pixels.
        '';
      };

      border = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Border size in pixels.
        '';
      };

      padding = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Bar padding in pixels.
        '';
      };

      width = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Bar width in pixels.
        '';
      };

      height = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Bar height in pixels.
        '';
      };

      borderColor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Border color in the form of #AARRGGBB.
        '';
      };

      backgroundColor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Background color in the form of #AARRGGBB.
        '';
      };

      barColor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Bar color in the form of #AARRGGBB.
        '';
      };

      outputs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Outputs to show the bar on. If this is an empty list,
          the bar will be shown on the focused output.
        '';
      };

      pipe = mkOption {
        type = types.str;
        default = "/tmp/wobpipe";
        description = ''
          Path to create the named pipe at.
        '';
      };

      systemdTarget = mkOption {
        type = types.str;
        default = "graphical-session.target";
        description = ''
          Systemd target to install for.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.wob = {
      Unit = {
        Description =
          "A lightweight overlay volume/backlight/progress/anything bar for Wayland.";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStartPre = "-${pkgs.coreutils}/bin/mkfifo ${cfg.pipe}";
        ExecStart = let
          wobCall = toString ([
            "${cfg.package}/bin/wob"
            (optional (cfg.timeout != null) "--timeout ${toString cfg.timeout}")
            (optional (cfg.max != null) "--max ${toString cfg.max}")
            (optional (cfg.width != null) "--width ${toString cfg.width}")
            (optional (cfg.height != null) "--height ${toString cfg.height}")
            (optional (cfg.offset != null) "--offset ${toString cfg.offset}")
            (optional (cfg.border != null) "--border ${toString cfg.border}")
            (optional (cfg.padding != null) "--padding ${toString cfg.padding}")
            (optional (cfg.margin != null) "--margin ${toString cfg.margin}")
            (optional (cfg.borderColor != null)
              "--border-color ${toString cfg.borderColor}")
            (optional (cfg.backgroundColor != null)
              "--background-color ${toString cfg.backgroundColor}")
            (optional (cfg.barColor != null)
              "--bar-color ${toString cfg.barColor}")
          ] ++ (map (a: "--anchor ${a}") cfg.anchors)
            ++ (map (o: "--output ${o}") cfg.outputs));
        in ''
          ${pkgs.bash}/bin/sh -c "${pkgs.coreutils}/bin/tail -f ${cfg.pipe} | ${wobCall}"
        '';
        ExecStopPost = "-${pkgs.coreutils}/bin/rm ${cfg.pipe}";
      };

      Install = { WantedBy = [ cfg.systemdTarget ]; };
    };
  };
}
