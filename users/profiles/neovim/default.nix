{ pkgs, ... }:

{
  programs.neovim = rec {
    enable = true;
    package = pkgs.neovim;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
      packadd packer.nvim
      luafile ~/.config/nvim/init_.lua
    '';

    plugins = with pkgs.vimPlugins; [
      {
        # This override is necessary as packer.nvim hardcodes this name in its load script.
        plugin = packer-nvim.overrideAttrs (old: { pname = "packer.nvim"; });
        optional = true;
      }
    ];
  };

  xdg.configFile."nvim/init_.lua".source = ./init.lua;
}
