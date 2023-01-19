{ config, ... }:

{
  home-manager.users.matrss = { pkgs, ... }: {
    imports = [
      ../profiles/neovim
      ../profiles/direnv
    ];

    home.packages = with pkgs; [
      git-annex
      datalad
      unrar
      conda
      sshuttle
      ripgrep
      fd
      git
      tig
      bitwarden-cli
      autossh
      nodePackages.tiddlywiki
    ];

    home.homeDirectory = "/home/matrss";
    home.sessionVariables.EDITOR = "nvim";

    xdg.enable = true;
    xdg.userDirs.enable = true;

    programs.git = {
      enable = true;
      userName = "Matthias Riße";
      # userEmail = "matthias.risze@t-online.de";
      userEmail = "m.risse@fz-juelich.de";
      # includes = [
      #   {
      #     condition = "gitdir:~/Projects/fzj/";
      #     contents = {
      #       user = {
      #         name = "Matthias Riße";
      #         email = "m.risse@fz-juelich.de";
      #       };
      #     };
      #   }
      # ];
      extraConfig = {
        pull.ff = "only";
        init.defaultBranch = "main";
        rebase.autosquash = true;
        rebase.autostash = true;
      };
    };

    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableScDaemon = true;
      pinentryFlavor = "gnome3";
    };

    programs.bash.enable = true;
    programs.tmux.enable = true;
    programs.tmux.baseIndex = 1;
    programs.tmux.clock24 = true;
    programs.tmux.newSession = true;

    programs.vscode.enable = true;
    programs.vscode.package = pkgs.vscodium;
    programs.vscode.extensions = with pkgs.vscode-extensions; [
      asvetliakov.vscode-neovim
      streetsidesoftware.code-spell-checker
      ms-vscode-remote.remote-ssh
      mkhl.direnv
      editorconfig.editorconfig
      donjayamanne.githistory
      alefragnani.project-manager
      james-yu.latex-workshop
      bbenoist.nix
      ms-python.python
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      vadimcn.vscode-lldb
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "signageos-vscode-sops";
        publisher = "signageos";
        version = "0.6.1";
        sha256 = "sha256-fHXiIfc+EXGzR1nl9x87nyKVvLGS1zW6hV5D0CxvUCg=";
      }
      {
        name = "base16-themes";
        publisher = "AndrsDC";
        version = "1.4.5";
        sha256 = "sha256-molx+cRKSB6os7pDr0U1v/Qbaklps+OvBkZCkSWEvWM=";
      }
      {
        name = "code-spell-checker-german";
        publisher = "streetsidesoftware";
        version = "2.1.0";
        sha256 = "sha256-9IX7Vl7wqeDyJ5f6+HVpndfmIOQadvRmtogvNLfGCvw=";
      }
      {
        name = "code-spell-checker-scientific-terms";
        publisher = "streetsidesoftware";
        version = "0.1.6";
        sha256 = "sha256-g6GD8ie9E5SmImxe9hBQe8ZSF+nKQMlZzoK7dm2NIW4=";
      }
      {
        name = "excalidraw-editor";
        publisher = "pomdtr";
        version = "3.3.4";
        sha256 = "sha256-a3WECVmyz1fTAnK1SApsNlLKNVq/BPC0t3fArN2P/60=";
      }
    ];

    home.stateVersion = "20.09";
  };

  sops.secrets.user-password-matrss = {
    sopsFile = ../../../secrets/secrets.yaml;
    neededForUsers = true;
  };

  users.users.matrss = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    passwordFile = config.sops.secrets.user-password-matrss.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByQhPnALCgo9Q4FbqYBCSTbMbP6OuSNmgRafdDo6yAx matrss@ipsmin"
    ];
  };
}
