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
      "/var/lib/nextcloud" = { hostPath = "/srv/data/nextcloud/data"; isReadOnly = false; };
      "/var/lib/postgresql" = { hostPath = "/srv/data/nextcloud/pg-data"; isReadOnly = false; };
      "${config.sops.secrets.nextcloud-admin-password.path}" = { hostPath = "${config.sops.secrets.nextcloud-admin-password.path}"; isReadOnly = true; };
    };
    config = { pkgs, ... }: {
      services.nextcloud.enable = true;
      services.nextcloud.package = pkgs.nextcloud23;
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

      services.redis.servers.nextcloud.enable = true;
      services.redis.servers.nextcloud.unixSocketPerm = 770;

      users.users.nginx.extraGroups = [ "redis-nextcloud" ];
      users.users.nextcloud.extraGroups = [ "redis-nextcloud" ];

      networking.firewall.allowedTCPPorts = [ 80 ];

      system.stateVersion = "21.11";
    };
  };
}
