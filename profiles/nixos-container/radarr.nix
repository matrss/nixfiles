{ config, lib, ... }:

{
  containers.radarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.21";
    localAddress = "10.11.1.21";
    bindMounts = {
      "${config.containers.radarr.config.services.radarr.dataDir}" = { hostPath = "/srv/radarr/config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      services.radarr.enable = true;
      ids.uids.radarr = lib.mkForce 1000;
      users.users.radarr.isSystemUser = true;
      networking.firewall.allowedTCPPorts = [ 7878 ];
      system.stateVersion = "21.11";
    };
  };

  services.nginx.virtualHosts."radarr.ara.matrss.de" = {
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
      proxyPass = "http://${config.containers.radarr.localAddress}:7878";
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
