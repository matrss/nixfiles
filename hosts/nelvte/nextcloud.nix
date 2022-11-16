{ pkgs, config, ... }:

{
  sops.secrets.nextcloud-admin-password = {
    owner = config.users.users.nextcloud.name;
    inherit (config.users.users.nextcloud) group;
  };

  services.nextcloud.enable = true;
  services.nextcloud.package = pkgs.nextcloud25;
  services.nextcloud.hostName = "cloud.matrss.xyz";
  services.nextcloud.https = true;
  services.nextcloud.webfinger = true;
  services.nextcloud.caching.redis = true;
  services.nextcloud.config = {
    adminuser = "admin";
    adminpassFile = "${config.sops.secrets.nextcloud-admin-password.path}";
    dbtype = "pgsql";
    dbhost = "/run/postgresql";
    dbname = "nextcloud";
    dbuser = "nextcloud";
    defaultPhoneRegion = "DE";
  };

  services.postgresql.ensureUsers = [
    {
      name = "nextcloud";
      ensurePermissions = {
        "DATABASE nextcloud" = "ALL PRIVILEGES";
      };
    }
  ];
  services.postgresql.ensureDatabases = [ "nextcloud" ];

  services.redis.servers.nextcloud.enable = true;
  services.redis.servers.nextcloud.unixSocketPerm = 770;

  users.users.nginx.extraGroups = [ "redis-nextcloud" ];
  users.users.nextcloud.extraGroups = [ "redis-nextcloud" ];

  services.nginx.virtualHosts."cloud.matrss.xyz" = {
    forceSSL = true;
    useACMEHost = "nelvte.matrss.xyz";
  };

  systemd.services.before-restic-backups-local-backup.preStart = ''
    nextcloud-occ maintenance:mode --on
  '';

  systemd.services.after-restic-backups-local-backup.postStart = ''
    nextcloud-occ maintenance:mode --off
  '';
}
