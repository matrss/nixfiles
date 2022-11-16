{
  programs.neovim = rec {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;

    # extraConfig = ''
    #   packadd packer.nvim
    #   luafile ~/.config/nvim/init_.lua
    # '';

    # extraPackages = with pkgs; [
    #   # General tooling
    #   git
    #   fd
    #   ripgrep

    #   # To compile tree-sitter grammars
    #   gcc

    #   # For vimtex
    #   neovim-remote
    # ];

    # plugins = with pkgs.vimPlugins; [
    #   {
    #     # This override is necessary as packer.nvim hardcodes this name in its load script.
    #     plugin = packer-nvim.overrideAttrs (_: { pname = "packer.nvim"; });
    #     optional = true;
    #   }
    # ];
  };

  # xdg.configFile."nvim/init_.lua".source = ./init.lua;
}
