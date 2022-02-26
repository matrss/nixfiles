{ pkgs, ... }:

{
  home-manager.users.matrss = { config, pkgs, ... }: {
    imports = [
      ../profiles/neovim
      ../profiles/direnv
    ];

    home.packages = with pkgs; [
      git-annex
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

  users.users.matrss = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF5mtCDOZCqK5JhMN+UZLOd8ua2rk9IOyuR+79q+szgW+PpwG0FFkQWoy31YhL0oTEe34txf9nling8XAgv6iYwJ6SV6Y5mw17NWlLiqar5mVrk7u2VG8VOeaM1aQYZVbHTgxShxRVDZinda22EAnYnzLrAqqQvb3OR2mpOgt/5KxdtR1+aj63TAVgICqOCW7/POTL4Lul3dXLoLf2OqtUwC99OasOcWUmzCrOAuh/egSXQzz8RZ4/vmLvzdFI67DiBtAI0VnADHQmhw98Z6zrdLOdoH12XqlYLlf+MUVxjRQAZz1EZ1rnaI2rJGQEifK84cMUQ2/lI0GDxeIOMOT8eUJFAV7B0dE7Pxy8Ulw3DNHYZqk0O7al9qiQPcTjht4Ae7NLyX43z2NlWf9ISkbqENqpD/py6pmf3D5qt/gN6EI0daZtpP81gS2iFVVRhIymeSQNxD54Yugw62Mcq9nurYZZPPZWHe0qakqnJfBRcOGN6pStboyOaHAp5q2Wn1HcdM7LOViVNRXsfnSGhiSJACcXwKA0gbq2o+JMqzq3u0OiMxb5ZFqyDt6lPy8vKvsKw0J89JHMLMg5s4A/DDU7YFfICpGZPLW+mhz789jMvOo9SYHFM7KhK9HXxKNvGpjS8OK736z8FXzOsHqcbNpjXXIccruIC1RI+QlYf8jLIw== cardno:000609614342"
    ];
  };
}
