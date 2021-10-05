{ pkgs, ... }:

{
  home-manager.users.matrss = { config, pkgs, ... }: {
    imports = [
      ../profiles/neovim
      ../profiles/direnv
      ../profiles/zsh.nix
      ../profiles/tmux.nix
    ];

    home.packages = with pkgs; [
      # datalad
      git-annex
      # (python3.withPackages (ps: with ps; [ pip ]))

      cargo

      unrar
      conda
      mpv
      todo-txt-cli
      sshuttle
      ripgrep
      fd
      git
      gitsh
      tig

      neuron-notes
      zk

      et

      youtube-dl

      bitwarden-cli

      rstudio
      # (vscode-with-extensions.override {
      #   vscodeExtensions = with vscode-extensions; [
      #     vscodevim.vim
      #     ms-vsliveshare.vsliveshare
      #     ms-python.python
      #     ms-toolsai.jupyter
      #   ];
      # })
      # dcraw
      # filebot
      # tinymediamanager
    ];

    home.homeDirectory = "/home/matrss";

    home.sessionVariables = {
      # Native wayland support for firefox
      MOZ_ENABLE_WAYLAND = "1";
      # EDITOR = "neovide --geometry=195x45";
      EDITOR = "nvim";
      ZK_NOTEBOOK_DIR = "${config.home.homeDirectory}/Sync/zettelkasten";
    };

    xdg.enable = true;
    xdg.userDirs.enable = true;

    # xdg.mime.enable = true;
    # xdg.mimeApps.enable = true;
    # xdg.mimeApps.defaultApplications = {
    #   # Open PDF files with xournalpp
    #   # "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    #   "application/pdf" = [ "com.github.xournalpp.xournalpp.desktop" ];

    #   # Use feh as image viewer
    #   "image/png" = [ "feh.desktop" ];
    #   "image/jpeg" = [ "feh.desktop" ];

    #   # Firefox as default browser
    #   "text/html" = [ "firefox.desktop" ];
    #   "text/xml" = [ "firefox.desktop" ];
    #   "application/xhtml+xml" = [ "firefox.desktop" ];
    #   "x-scheme-handler/http" = [ "firefox.desktop" ];
    #   "x-scheme-handler/https" = [ "firefox.desktop" ];
    #   "x-scheme-handler/ftp" = [ "firefox.desktop" ];
    #   "x-scheme-handler/about" = [ "firefox.desktop" ];
    #   "x-scheme-handler/unknown" = [ "firefox.desktop" ];

    #   # Thunderbird as default mail client
    #   "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
    #   "message/rfc822" = [ "thunderbird.desktop" ];
    # };

    # fonts.fontconfig.enable = true;

    # gtk = {
    #   enable = true;
    #   theme = {
    #     name = "Numix";
    #     package = pkgs.numix-gtk-theme;
    #   };
    #   iconTheme = {
    #     name = "Numix";
    #     package = pkgs.numix-icon-theme;
    #   };
    #   font = {
    #     name = "Noto Sans 11";
    #     package = pkgs.noto-fonts;
    #   };
    # };

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
      pinentryFlavor = "qt";
    };

    services.syncthing.enable = true;

    xdg.configFile."todotxt/todo.cfg".source = ./todotxt/todo.cfg;

    home.stateVersion = "20.09";
  };

  # Fix for zsh completion for system apps
  environment.pathsToLink = [ "/share/zsh" ];

  users.users.matrss = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF5mtCDOZCqK5JhMN+UZLOd8ua2rk9IOyuR+79q+szgW+PpwG0FFkQWoy31YhL0oTEe34txf9nling8XAgv6iYwJ6SV6Y5mw17NWlLiqar5mVrk7u2VG8VOeaM1aQYZVbHTgxShxRVDZinda22EAnYnzLrAqqQvb3OR2mpOgt/5KxdtR1+aj63TAVgICqOCW7/POTL4Lul3dXLoLf2OqtUwC99OasOcWUmzCrOAuh/egSXQzz8RZ4/vmLvzdFI67DiBtAI0VnADHQmhw98Z6zrdLOdoH12XqlYLlf+MUVxjRQAZz1EZ1rnaI2rJGQEifK84cMUQ2/lI0GDxeIOMOT8eUJFAV7B0dE7Pxy8Ulw3DNHYZqk0O7al9qiQPcTjht4Ae7NLyX43z2NlWf9ISkbqENqpD/py6pmf3D5qt/gN6EI0daZtpP81gS2iFVVRhIymeSQNxD54Yugw62Mcq9nurYZZPPZWHe0qakqnJfBRcOGN6pStboyOaHAp5q2Wn1HcdM7LOViVNRXsfnSGhiSJACcXwKA0gbq2o+JMqzq3u0OiMxb5ZFqyDt6lPy8vKvsKw0J89JHMLMg5s4A/DDU7YFfICpGZPLW+mhz789jMvOo9SYHFM7KhK9HXxKNvGpjS8OK736z8FXzOsHqcbNpjXXIccruIC1RI+QlYf8jLIw== cardno:000609614342"
    ];
  };
}
