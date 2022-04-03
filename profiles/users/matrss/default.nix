{ config, pkgs, ... }:

{
  home-manager.users.matrss = { config, pkgs, ... }: {
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
      nodePackages.tiddlywiki
    ];

    home.homeDirectory = "/home/matrss";
    home.sessionVariables.EDITOR = "nvim";

    xdg.enable = true;
    xdg.userDirs.enable = true;

    programs.git = {
      enable = true;
      userName = "Matthias Riße";
      userEmail = "matthias.risze@t-online.de";
      includes = [
        {
          condition = "gitdir:~/Projects/fzj/";
          contents = {
            user = {
              name = "Matthias Riße";
              email = "m.risse@fz-juelich.de";
            };
          };
        }
      ];
      extraConfig = { pull = { ff = "only"; }; init = { defaultBranch = "main"; }; };
    };

    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableScDaemon = true;
      pinentryFlavor = "gnome3";
    };

    services.syncthing.enable = true;

    programs.bash.enable = true;

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgAt4vG44X0LcB5Xcxzhx+Yxug7z5QbD7YRjKONBTVn Matthias Riße"
    ];
  };
}
