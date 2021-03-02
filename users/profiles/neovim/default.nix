{ pkgs, ... }:

{
  programs.neovim = rec {
    package = pkgs.neovim-nightly;
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;

    # extraPython3Packages = ps: with ps; [ tasklib setuptools ];
    extraPython3Packages = ps: with ps; [ setuptools ];

    extraPackages = with pkgs; [
      gcc
      fd
      ripgrep
      bat
      rust-analyzer
      cargo
      python-language-server
    ];

    extraConfig = builtins.readFile ./init.vim;

    plugins = with pkgs.vimPlugins;
      let
        base16-vim-lightline = pkgs.vimUtils.buildVimPlugin {
          name = "base16-vim-lightline";

          src = pkgs.fetchFromGitHub {
            owner = "mike-hearn";
            repo = "base16-vim-lightline";
            rev = "master";
            sha256 = "sha256-Sbkx/2RTa/UEW82aNf9Rlyd6vRAbSyn1pgPMNWdknVE=";
          };
        };
        vim-waikiki = pkgs.vimUtils.buildVimPlugin {
          name = "vim-waikiki";

          src = pkgs.fetchFromGitHub {
            owner = "fcpg";
            repo = "vim-waikiki";
            rev = "master";
            sha256 = "sha256-8zMKrmCV4Erp0Q4WyuqyyKgZS5JGu1dXSzrhftdmNFE=";
          };
        };
        # nvim-base16-lua = pkgs.vimUtils.buildVimPlugin {
        #   name = "nvim-base16.lua";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "norcalli";
        #     repo = "nvim-base16.lua";
        #     rev = "master";
        #     sha256 = "sha256-uFpYeUfMMu3rJjxJZyyqFYAa2q2EcW2sSIBfP+vhb1g=";
        #   };
        # };
      in [
        vim-sensible
        vim-polyglot
        vim-which-key
        # vimwiki
        # indentLine
        goyo-vim
        limelight-vim
        vim-snippets
        vim-fugitive
        lightline-vim
        base16-vim
        onedark-vim
        ayu-vim
        base16-vim-lightline
        vim-rooter
        # vim-gitgutter
        vim-signify

        vim-commentary
        targets-vim
        vim-surround
        vim-tmux-navigator

        vim-vinegar
        vim-waikiki
        vim-pandoc
        vim-pandoc-syntax
        vimtex
        direnv-vim
        todo-txt-vim

        popup-nvim
        plenary-nvim
        telescope-nvim

        auto-pairs
        # jupytext-vim
      ] ++ [
        nvim-lspconfig
        lsp_extensions-nvim
        completion-nvim
        # diagnostic-nvim
      ] ++ [
        nvim-treesitter
        # completion-treesitter
      ]; # ++ cocPlugins;
  };

  xdg.configFile."nvim/after".source = ./nvim/after;
}
