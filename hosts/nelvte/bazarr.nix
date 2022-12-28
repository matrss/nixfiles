{
  services.bazarr.enable = true;

  systemd.services.before-restic-backups-local-backup.preStart = ''
    systemctl stop bazarr.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = ''
    systemctl start bazarr.service
  '';
}
