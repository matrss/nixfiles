{ pkgs, ... }:

{
  home-manager.users.matrss = {
    home.packages = with pkgs; [ unrar ];
  };

  users.users.matrss = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgAt4vG44X0LcB5Xcxzhx+Yxug7z5QbD7YRjKONBTVn Matthias Riße"
    ];
  };
}