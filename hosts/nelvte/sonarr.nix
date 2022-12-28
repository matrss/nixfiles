{
  services.sonarr.enable = true;

  systemd.services.before-restic-backups-local-backup.preStart = ''
    systemctl stop sonarr.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = ''
    systemctl start sonarr.service
  '';
}
