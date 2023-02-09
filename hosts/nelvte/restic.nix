{ config, ... }:

{
  sops.secrets."restic/repository-password" = { };

  services.restic.backups.local-backup = {
    repository = "/backup/restic-repo";
    paths = [ ];
    passwordFile = config.sops.secrets."restic/repository-password".path;
  };
}
