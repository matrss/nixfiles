{ pkgs, ... }:

{
  home.packages = with pkgs; [ noto-fonts ];

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 11;
        normal.family = "Noto Sans Mono";
        bold.family = "Noto Sans Mono";
        italic.family = "Noto Sans Mono";
        bold_italic.family = "Noto Sans Mono";
      };
    };
  };
}
