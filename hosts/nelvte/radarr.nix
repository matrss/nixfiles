{
  services.radarr.enable = true;

  systemd.services.before-restic-backups-local-backup.preStart = ''
    systemctl stop radarr.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = ''
    systemctl start radarr.service
  '';
}
