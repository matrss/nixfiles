{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [{
      layer = "bottom";
      position = "bottom";
      height = 0;
      width = 0;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [
        "custom/launcher"
        "custom/layout"
        "idle_inhibitor"
        "pulseaudio"
        "battery"
        "clock"
      ];
      modules = {
        "custom/layout" = {
          "format" = "L";
          "on-click" = "swaymsg layout toggle split tabbed";
        };
        "custom/launcher" = {
          "format" = "launch";
          "on-click" = "nwggrid";
        };
        "sway/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = false;
        };
        "sway/mode" = {
          # "format" = "<span style=\"italic\">{}</span>"
        };
        "clock" = {
          "format" = "time: {:%H:%M}";
          "format-alt" = "date: {:%Y-%m-%d}";
        };
        "battery" = {
          "bat" = "BAT0";
          "states" = {
            "full" = 100;
            "good" = 95;
            "warning" = 15;
            "critical" = 10;
          };
          "format" = "bat:{capacity:3}%";
          # "format-good" = "";
          "format-full" = "";
        };
        "pulseaudio" = {
          "format" = "vol:{volume:3}%";
          "format-muted" = "vol: ---";
        };
        "idle_inhibitor" = { "format" = "inhibit: {status:3}"; };
      };
    }];

    style = builtins.readFile ./style.css;
  };
}
