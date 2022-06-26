{ config, ... }:

{
  sops.secrets."restic/repository-password" = { };

  services.restic.backups.local-backup = {
    repository = "/backup/restic-repo";
    paths = [
      "/var/lib/authelia"
      "/var/lib/bazarr"
      "/var/lib/hydra"
      "/var/lib/jellyfin"
      "/var/lib/nextcloud"
      "/var/lib/postgresql"
      "/var/lib/radarr"
      "/var/lib/sonarr"
      "/var/lib/tiddlywiki"
    ];
    passwordFile = config.sops.secrets."restic/repository-password".path;
  };

  # We do not actually use the snapshot, because restic does not allow rewriting paths for backed up files (yet).
  # Therefore we just accept more down time and backup from the source location instead of a snapshot.
  # See https://github.com/restic/restic/pull/3200 for path rewriting in restic.
  # These services are still used to attach pre-/postStart scripts to bring services into a consistent state for the backup.
  systemd.services.before-restic-backups-local-backup = {
    description = "Prepare system for backup";
    partOf = [ "restic-backups-local-backup.service" ];
    wantedBy = [ "restic-backups-local-backup.service" ];
    before = [ "restic-backups-local-backup.service" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # btrfs subvolume snapshot -r /data-root/varlib/ /data-root/snapshots/varlib_tmp_local-backup
    '';
  };

  systemd.services.after-restic-backups-local-backup = {
    description = "Cleanup after a backup";
    partOf = [ "restic-backups-local-backup.service" ];
    wantedBy = [ "restic-backups-local-backup.service" ];
    after = [ "restic-backups-local-backup.service" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # btrfs subvolume delete /data-root/snapshots/varlib_tmp_local-backup
    '';
  };
}
