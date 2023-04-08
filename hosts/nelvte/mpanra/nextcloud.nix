{ pkgs, config, ... }:

{
  sops.secrets.nextcloud-admin-password = {
    owner = config.users.users.nextcloud.name;
    inherit (config.users.users.nextcloud) group;
  };

  services.nextcloud.enable = true;
  services.nextcloud.package = pkgs.nextcloud26;
  services.nextcloud.hostName = "cloud.0px.xyz";
  services.nextcloud.https = true;
  services.nextcloud.webfinger = true;
  services.nextcloud.enableBrokenCiphersForSSE = false;
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

  services.nginx.virtualHosts."cloud.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "mpanra.m.0px.xyz";
  };
}
