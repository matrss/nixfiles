{ pkgs, config, ... }:

{
  sops.secrets.nextcloud-admin-password = {
    owner = config.users.users.nextcloud.name;
    group = config.users.users.nextcloud.group;
  };

  services.nextcloud.enable = true;
  services.nextcloud.package = pkgs.nextcloud23;
  services.nextcloud.hostName = "nextcloud.ara.matrss.de";
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
