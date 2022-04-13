{ config, ... }:

{
  containers.jellyfin = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.30";
    localAddress = "10.11.1.30";
    bindMounts = {
      "/var/lib/jellyfin" = { hostPath = "/srv/jellyfin/config"; isReadOnly = false; };
      "/var/cache/jellyfin" = { hostPath = "/srv/jellyfin/cache"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = true; };
    };
    config = {
      services.jellyfin.enable = true;
      networking.firewall.allowedTCPPorts = [ 8096 ];
      system.stateVersion = "21.11";
    };
  };

  services.nginx.virtualHosts."jellyfin.ara.matrss.de" = {
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
      proxyPass = "http://${config.containers.jellyfin.localAddress}:8096";
      proxyWebsockets = true;
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
