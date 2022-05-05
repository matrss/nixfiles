{
  services.radarr.enable = true;

  services.nginx.virtualHosts."radarr.matrss.de" = {
    forceSSL = true;
    useACMEHost = "nelvte.matrss.de";
    locations."/verify" = {
      proxyPass = "http://127.0.0.1:9091/api/verify";
      extraConfig = ''
        internal;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
      '';
    };
    locations."/" = {
      proxyPass = "http://127.0.0.1:7878";
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
      error_page 401 =302 https://idp.matrss.de/?rd=$target_url;
    '';
  };

  systemd.services.before-restic-backups-local-backup.preStart = ''
    systemctl stop radarr.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = ''
    systemctl start radarr.service
  '';
}
