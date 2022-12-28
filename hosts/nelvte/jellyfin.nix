{
  services.jellyfin.enable = true;

  systemd.services.before-restic-backups-local-backup.preStart = ''
    systemctl stop jellyfin.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = ''
    systemctl start jellyfin.service
  '';
}
