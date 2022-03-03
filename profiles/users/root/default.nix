{ config, ... }:

let
  nixpkgs-config = config;
in
{
  home-manager.users.root = { config, pkgs, ... }: {
    programs.ssh = {
      enable = true;
      matchBlocks."ara-binary-cache" = {
        host = "ara-binary-cache";
        hostname = "ara.matrss.de";
        user = "nix-ssh";
        port = 22;
        identitiesOnly = true;
        identityFile = nixpkgs-config.sops.secrets.root-ssh-key.path;
      };
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgAt4vG44X0LcB5Xcxzhx+Yxug7z5QbD7YRjKONBTVn Matthias Riße"
  ];
}
