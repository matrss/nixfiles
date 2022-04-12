{ config, ... }:

{
  containers.sonarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.20";
    localAddress = "10.11.1.20";
    bindMounts = {
      "${config.containers.sonarr.config.services.sonarr.dataDir}" = { hostPath = "/srv/data/sonarr/config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      services.sonarr.enable = true;
      networking.firewall.allowedTCPPorts = [ 8989 ];
      system.stateVersion = "21.11";
    };
  };

  services.nginx.virtualHosts."sonarr.ara.matrss.de" = {
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
      proxyPass = "http://${config.containers.sonarr.localAddress}:8989";
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
