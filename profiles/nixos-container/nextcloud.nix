{ config, ... }:

{
  sops.secrets.nextcloud-admin-password.mode = "0444";

  containers.nextcloud = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.10";
    localAddress = "10.11.1.10";
    bindMounts = {
      "/var/lib/nextcloud" = { hostPath = "/volumes/nextcloud-data"; isReadOnly = false; };
      "/var/lib/postgresql" = { hostPath = "/volumes/nextcloud-db-data"; isReadOnly = false; };
      "${config.sops.secrets.nextcloud-admin-password.path}" = { hostPath = "${config.sops.secrets.nextcloud-admin-password.path}"; isReadOnly = true; };
    };
    config = {
      services.nextcloud.enable = true;
      services.nextcloud.hostName = "nextcloud.ara.matrss.de";
      services.nextcloud.https = true;
      services.nextcloud.caching.redis = true;
      services.nextcloud.config = {
        adminuser = "admin";
        adminpassFile = "${config.sops.secrets.nextcloud-admin-password.path}";
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        defaultPhoneRegion = "DE";
        overwriteProtocol = "https";
      };

      services.postgresql = {
        enable = true;
        ensureUsers = [{
          name = "nextcloud";
          ensurePermissions = {
            "DATABASE nextcloud" = "ALL PRIVILEGES";
          };
        }];
        ensureDatabases = [ "nextcloud" ];
      };

      services.redis.enable = true;
      services.redis.unixSocket = "/run/redis/redis.sock";
      services.redis.unixSocketPerm = 770;

      users.users.nginx.extraGroups = [ "redis" ];
      users.users.nextcloud.extraGroups = [ "redis" ];

      networking.firewall.allowedTCPPorts = [ 80 ];

      system.stateVersion = "21.11";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.nextcloud = {
      rule = "Host(`nextcloud.ara.matrss.de`)";
      entryPoints = [ "websecure" ];
      middlewares = [ "secured" ];
      service = "nextcloud";
    };
    services.nextcloud.loadBalancer.servers = [{ url = "http://${config.containers.nextcloud.localAddress}:80"; }];
  };
}
