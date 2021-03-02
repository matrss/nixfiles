{ config, lib, pkgs, ... }:

let hmConfig = config;
in {
  imports = [
    ./waybar
    ./bemenu.nix
    ./alacritty.nix
    ./mako.nix
    ./wob.nix
    ./autorotate.nix
    ./wlsunset.nix
  ];

  home.packages = with pkgs; [
    qt5.qtbase
    qt5.qtwayland
    breeze-icons
    breeze-qt5
  ];

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  wayland.windowManager.sway = rec {
    enable = true;

    wrapperFeatures = {
      base = true;
      gtk = true;
    };

    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      # Necessary for xdg-desktop-portal (screen sharing)
      export XDG_CURRENT_DESKTOP=sway
      # This should fix broken QT Applications (can't find plugin... errors)
      # Does this need qt5wayland?
      export QT_QPA_PLATFORM="wayland;xcb"
      # Native wayland support for firefox
      export MOZ_ENABLE_WAYLAND=1
      # Fix for broken Java AWT applications (empty window)
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';

    extraConfig = ''
      # Set the cursor theme to breeze at size 24
      seat seat0 xcursor_theme breeze_cursors 24

      # The following is taken from https://github.com/rkubosz/base16-sway
      ## Base16 Eighties
      # Author: Chris Kempson (http://chriskempson.com)

      set $base00 #2d2d2d
      set $base01 #393939
      set $base02 #515151
      set $base03 #747369
      set $base04 #a09f93
      set $base05 #d3d0c8
      set $base06 #e8e6df
      set $base07 #f2f0ec
      set $base08 #f2777a
      set $base09 #f99157
      set $base0A #ffcc66
      set $base0B #99cc99
      set $base0C #66cccc
      set $base0D #6699cc
      set $base0E #cc99cc
      set $base0F #d27b53

      # Basic color configuration using the Base16 variables for windows and borders.
      # Property Name         Border  BG      Text    Indicator Child Border
      client.focused          $base05 $base0D $base00 $base0D $base0D
      client.focused_inactive $base01 $base01 $base05 $base03 $base01
      client.unfocused        $base01 $base00 $base05 $base01 $base01
      client.urgent           $base08 $base08 $base00 $base08 $base08
      client.placeholder      $base00 $base00 $base05 $base00 $base00
      client.background       $base07
    '';

    config = {
      modifier = "Mod1";

      terminal = "${pkgs.alacritty}/bin/alacritty";

      # menu = "${pkgs.wofi}/bin/wofi --gtk-dark --show drun";
      menu = "${pkgs.bemenu}/bin/bemenu-run";

      fonts = [ "Noto Sans Mono 11" ];

      assigns = {
        "1" = [{ app_id = "firefox"; }];
        "6" = [{ app_id = "thunderbird"; }];
        "8" = [{
          class = "Spotify";
          instance = "spotify";
        }];
      };

      # colors = {
      #   focused = {
      #     background = "#285577";
      #     border = "#4c7899";
      #     childBorder = "#285577";
      #     indicator = "#2e9ef4";
      #     text = "#ffffff";
      #   };

      #   focusedInactive = {
      #     background = "#5f676a";
      #     border = "#333333";
      #     childBorder = "#5f676a";
      #     indicator = "#484e50";
      #     text = "#ffffff";
      #   };

      #   placeholder = {
      #     background = "#0c0c0c";
      #     border = "#000000";
      #     childBorder = "#0c0c0c";
      #     indicator = "#000000";
      #     text = "#ffffff";
      #   };

      #   unfocused = {
      #     background = "#222222";
      #     border = "#333333";
      #     childBorder = "#222222";
      #     indicator = "#292d2e";
      #     text = "#888888";
      #   };

      #   urgent = {
      #     background = "#900000";
      #     border = "#2f343a";
      #     childBorder = "#900000";
      #     indicator = "#900000";
      #     text = "#ffffff";
      #   };
      # };

      input = {
        "type:keyboard" = { xkb_layout = "eu"; };
        "1386:20914:Wacom_Pen_and_multitouch_sensor_Finger" = {
          map_to_output = "eDP-1";
        };
        "1386:20914:Wacom_Pen_and_multitouch_sensor_Pen" = {
          map_to_output = "eDP-1";
        };
        "2:10:TPPS/2_Elan_TrackPoint" = {
          accel_profile = "adaptive";
          # pointer_accel = "-0.25";
        };
      };

      keybindings = let
        modifier = config.modifier;
        wobpipe = hmConfig.services.wob.pipe;
      in lib.mkOptionDefault {
        "${modifier}+p" = "exec ${pkgs.menupass}/bin/menupass";
        "${modifier}+Tab" =
          "exec ${pkgs.sway}/bin/swaymsg workspace back_and_forth";
        "XF86AudioLowerVolume" =
          "exec ${pkgs.pamixer}/bin/pamixer -d 5 && ${pkgs.pamixer}/bin/pamixer --unmute && ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobpipe}";
        "XF86AudioRaiseVolume" =
          "exec ${pkgs.pamixer}/bin/pamixer -i 5 && ${pkgs.pamixer}/bin/pamixer --unmute && ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobpipe}";
        "XF86AudioMute" =
          "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && (${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > ${wobpipe}) || ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobpipe}";
        "XF86AudioMicMute" =
          "exec ${pkgs.pamixer}/bin/pamixer --source 1 --toggle-mute";
        "XF86MonBrightnessUp" =
          "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5% && ${pkgs.brightnessctl}/bin/brightnessctl -m i | cut -d',' -f4 | tr -d '%' > ${wobpipe}";
        "XF86MonBrightnessDown" =
          "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%- && ${pkgs.brightnessctl}/bin/brightnessctl -m i | cut -d',' -f4 | tr -d '%' > ${wobpipe}";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "Print" =
          ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)"'';
      };

      # keycodebindings = {
      #   "197" =
      #     "${pkgs.libnotify}/bin/notify-send double click"; # pen double click
      #   "198" = "${pkgs.libnotify}/bin/notify-send single click"; # pen click
      # };

      output = { "*" = { bg = "~/Pictures/Wallpapers/river.png fill"; }; };

      # Empty list to disable bars completly (waybar runs as a systemd service)
      bars = [ ];

      startup = [
        # {
        #   command = ''
        #     ${pkgs.swayidle}/bin/swayidle -w \
        #       timeout 300 '${pkgs.swaylock-effects}/bin/swaylock --screenshots --effect-blur 7x5 --effect-greyscale --clock --indicator --inside-color 00000000 --inside-clear-color 00000000 --inside-caps-lock-color 00000000 --inside-ver-color 00000000 --inside-wrong-color 00000000 --key-hl-color 00000000 --layout-bg-color 00000000 --layout-border-color 00000000 --layout-text-color 00000000 --line-color 00000000 --line-clear-color 00000000 --line-caps-lock-color 00000000 --line-ver-color 00000000 --line-wrong-color 00000000 --ring-color 00000000 --ring-clear-color 00000000 --ring-caps-lock-color 00000000 --ring-ver-color 00000000 --ring-wrong-color 00000000 --separator-color 00000000 --grace 2 --no-unlock-indicator' \
        #       timeout 600 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
        #       resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
        #       before-sleep '${pkgs.swaylock-effects}/bin/swaylock --screenshots --effect-blur 7x5 --effect-greyscale --clock --indicator --inside-color 00000000 --inside-clear-color 00000000 --inside-caps-lock-color 00000000 --inside-ver-color 00000000 --inside-wrong-color 00000000 --key-hl-color 00000000 --layout-bg-color 00000000 --layout-border-color 00000000 --layout-text-color 00000000 --line-color 00000000 --line-clear-color 00000000 --line-caps-lock-color 00000000 --line-ver-color 00000000 --line-wrong-color 00000000 --ring-color 00000000 --ring-clear-color 00000000 --ring-caps-lock-color 00000000 --ring-ver-color 00000000 --ring-wrong-color 00000000 --separator-color 00000000 --no-unlock-indicator'
        #   '';
        # }
        {
          command = ''
            ${pkgs.swayidle}/bin/swayidle -w \
              timeout 300 '${pkgs.swaylock}/bin/swaylock -c 000000 --no-unlock-indicator' \
              timeout 600 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
              resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
              before-sleep '${pkgs.swaylock}/bin/swaylock -c 000000 --no-unlock-indicator'
          '';
        }
      ];
    };
  };
}
