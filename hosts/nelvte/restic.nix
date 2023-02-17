{ config, pkgs, ... }:

{
  sops.secrets."restic/repository-password" = { };

  services.restic.backups.local-backup = {
    repository = "/backup/restic-repo";
    paths = [ "/data/snapshots/mpanra-varlib-local" ];
    passwordFile = config.sops.secrets."restic/repository-password".path;
    timerConfig = {
      OnCalendar = "01:00";
    };
    backupPrepareCommand = ''
      systemctl stop container@mpanra.service
      sleep 5
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /data/mpanra-varlib /data/snapshots/mpanra-varlib-local
      sleep 5
      systemctl start container@mpanra.service
    '';
    backupCleanupCommand = ''
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /data/snapshots/mpanra-varlib-local
    '';
  };

  sops.secrets."restic/ssh-keys/backup-box" = { };

  services.restic.backups.offsite-backup = {
    extraOptions = [
      "sftp.command='ssh u338890@u338890.your-storagebox.de -i ${config.sops.secrets."restic/ssh-keys/backup-box".path} -s sftp'"
    ];
    repository = "sftp:u338890@u338890.your-storagebox.de:backups/mpanra-varlib";
    paths = [ "/data/snapshots/mpanra-varlib-offsite" ];
    passwordFile = config.sops.secrets."restic/repository-password".path;
    timerConfig = {
      OnCalendar = "02:00";
    };
    backupPrepareCommand = ''
      systemctl stop container@mpanra.service
      sleep 5
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /data/mpanra-varlib /data/snapshots/mpanra-varlib-offsite
      sleep 5
      systemctl start container@mpanra.service
    '';
    backupCleanupCommand = ''
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /data/snapshots/mpanra-varlib-offsite
    '';
  };
}
