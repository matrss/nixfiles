{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovide
  ];

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

    extraPackages = with pkgs; [
      # General tooling
      git
      fd
      ripgrep

      # Cool zettels
      # neuron-notes

      # To compile tree-sitter grammars
      gcc

      # Language servers
      sumneko-lua-language-server
      rust-analyzer
      # fortls
      pyright
      clang-tools
      rnix-lsp
      nodePackages.bash-language-server
    ];

    plugins = with pkgs.vimPlugins; [
      {
        # This override is necessary as packer.nvim hardcodes this name in its load script.
        plugin = packer-nvim.overrideAttrs (old: { pname = "packer.nvim"; });
        optional = true;
      }
    ];
  };

  xdg.configFile."nvim/init_.lua".source = ./init.lua;
  # xdg.configFile."nvim/lua".source = ./nvim/lua;
}
