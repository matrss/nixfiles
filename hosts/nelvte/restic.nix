{ config, ... }:

{
  sops.secrets."restic/repository-password" = { };

  services.restic.backups.local-backup = {
    repository = "/backup/restic-repo";
    paths = [ "/data/snapshots/mpanra-varlib" ];
    passwordFile = config.sops.secrets."restic/repository-password".path;
  };

  systemd.services.before-restic-backups-local-backup = {
    description = "Prepare system for backup";
    partOf = [ "restic-backups-local-backup.service" ];
    wantedBy = [ "restic-backups-local-backup.service" ];
    before = [ "restic-backups-local-backup.service" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig.Type = "oneshot";
    script = ''
      systemctl stop container@mpanra.service
      btrfs subvolume snapshot -r /data/mpanra-varlib /data/snapshots/mpanra-varlib
      systemctl start container@mpanra.service
    '';
  };

  systemd.services.after-restic-backups-local-backup = {
    description = "Cleanup system after backup";
    partOf = [ "restic-backups-local-backup.service" ];
    wantedBy = [ "restic-backups-local-backup.service" ];
    after = [ "restic-backups-local-backup.service" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig.Type = "oneshot";
    script = ''
      btrfs subvolume delete /data/snapshots/mpanra-varlib
    '';
  };
}
