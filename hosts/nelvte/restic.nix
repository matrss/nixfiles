{ config, pkgs, ... }:

{
  sops.secrets."restic/repository-password" = { };

  services.restic.backups.local-backup = {
    repository = "/backup/restic-repo";
    paths = [ "/data/snapshots/mpanra-var-local" ];
    passwordFile = config.sops.secrets."restic/repository-password".path;
    timerConfig = {
      OnCalendar = "01:00";
    };
    backupPrepareCommand = ''
      systemctl stop container@mpanra.service
      sleep 5
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /data/mpanra-var /data/snapshots/mpanra-var-local
      sleep 5
      systemctl start container@mpanra.service
    '';
    backupCleanupCommand = ''
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /data/snapshots/mpanra-var-local
    '';
  };

  sops.secrets."restic/ssh-keys/backup-box" = { };

  services.restic.backups.offsite-backup = {
    extraOptions = [
      "sftp.command='ssh u338890@u338890.your-storagebox.de -i ${config.sops.secrets."restic/ssh-keys/backup-box".path} -s sftp'"
    ];
    repository = "sftp:u338890@u338890.your-storagebox.de:backups/mpanra-var";
    paths = [ "/data/snapshots/mpanra-var-offsite" ];
    passwordFile = config.sops.secrets."restic/repository-password".path;
    timerConfig = {
      OnCalendar = "02:00";
    };
    backupPrepareCommand = ''
      systemctl stop container@mpanra.service
      sleep 5
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /data/mpanra-var /data/snapshots/mpanra-var-offsite
      sleep 5
      systemctl start container@mpanra.service
    '';
    backupCleanupCommand = ''
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /data/snapshots/mpanra-var-offsite
    '';
  };
}
