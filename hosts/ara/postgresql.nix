{ lib, pkgs, config, ... }:

{
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_14;

  systemd.services.before-restic-backups-local-backup.preStart = lib.mkAfter ''
    systemctl stop postgresql.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = lib.mkBefore ''
    systemctl start postgresql.service
  '';
}
