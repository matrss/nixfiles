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
      "/var/lib/nextcloud" = { hostPath = "/srv/nextcloud/data"; isReadOnly = false; };
      "/var/lib/postgresql" = { hostPath = "/srv/nextcloud/pg-data"; isReadOnly = false; };
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

        trustedProxies = [ "${config.containers.nextcloud.hostAddress}" ];
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

  services.nginx.virtualHosts."nextcloud.ara.matrss.de" = {
    forceSSL = true;
    useACMEHost = "ara.matrss.de";
    locations."/verify" = {
      proxyPass = "http://127.0.0.1:9091/api/verify";
      extraConfig = ''
        internal;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
      '';
    };
    locations."/" = {
      proxyPass = "http://${config.containers.nextcloud.localAddress}";
      proxyWebsockets = true;
    };
    locations."/.well-known/caldav" = {
      return = "301 $scheme://$host/remote.php/dav";
    };
    locations."/.well-known/carddav" = {
      return = "301 $scheme://$host/remote.php/dav";
    };
    extraConfig = ''
      auth_request /verify;
      auth_request_set $target_url $scheme://$http_host$request_uri;
      auth_request_set $user $upstream_http_remote_user;
      auth_request_set $groups $upstream_http_remote_groups;
      auth_request_set $name $upstream_http_remote_name;
      auth_request_set $email $upstream_http_remote_email;
      proxy_set_header Remote-User $user;
      proxy_set_header Remote-Groups $groups;
      proxy_set_header Remote-Name $name;
      proxy_set_header Remote-Email $email;
      error_page 401 =302 https://idp.ara.matrss.de/?rd=$target_url;
    '';
  };
}
