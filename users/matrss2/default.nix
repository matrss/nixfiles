{ pkgs, ... }:

{
  imports = [ ];

  home-manager.users.matrss2 = {
    imports = [ ];

    home.packages = with pkgs;
      [
        # datalad
        git-annex
      ];

    programs.git = {
      enable = true;
      userName = "Matthias Riße";
      userEmail = "matthias.risze@t-online.de";
    };

    home.stateVersion = "20.09";
  };

  users.users.matrss2 = {
    uid = 1001;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF5mtCDOZCqK5JhMN+UZLOd8ua2rk9IOyuR+79q+szgW+PpwG0FFkQWoy31YhL0oTEe34txf9nling8XAgv6iYwJ6SV6Y5mw17NWlLiqar5mVrk7u2VG8VOeaM1aQYZVbHTgxShxRVDZinda22EAnYnzLrAqqQvb3OR2mpOgt/5KxdtR1+aj63TAVgICqOCW7/POTL4Lul3dXLoLf2OqtUwC99OasOcWUmzCrOAuh/egSXQzz8RZ4/vmLvzdFI67DiBtAI0VnADHQmhw98Z6zrdLOdoH12XqlYLlf+MUVxjRQAZz1EZ1rnaI2rJGQEifK84cMUQ2/lI0GDxeIOMOT8eUJFAV7B0dE7Pxy8Ulw3DNHYZqk0O7al9qiQPcTjht4Ae7NLyX43z2NlWf9ISkbqENqpD/py6pmf3D5qt/gN6EI0daZtpP81gS2iFVVRhIymeSQNxD54Yugw62Mcq9nurYZZPPZWHe0qakqnJfBRcOGN6pStboyOaHAp5q2Wn1HcdM7LOViVNRXsfnSGhiSJACcXwKA0gbq2o+JMqzq3u0OiMxb5ZFqyDt6lPy8vKvsKw0J89JHMLMg5s4A/DDU7YFfICpGZPLW+mhz789jMvOo9SYHFM7KhK9HXxKNvGpjS8OK736z8FXzOsHqcbNpjXXIccruIC1RI+QlYf8jLIw== cardno:000609614342"
    ];
  };
}
