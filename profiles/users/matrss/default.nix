{ config, ... }:

{
  home-manager.users.matrss = { pkgs, ... }: {
    imports = [
      ../profiles/neovim
      ../profiles/direnv
    ];

    home.packages = with pkgs; [
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
      vscodium-fhs
      nil
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

    home.stateVersion = "20.09";
  };

  sops.secrets.user-password-matrss = {
    sopsFile = ../../../secrets/secrets.yaml;
    neededForUsers = true;
  };

  users.users.matrss = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "kvm" ];
    passwordFile = config.sops.secrets.user-password-matrss.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByQhPnALCgo9Q4FbqYBCSTbMbP6OuSNmgRafdDo6yAx matrss@ipsmin"
    ];
  };
}
