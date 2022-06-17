{
  services.home-assistant.enable = true;
  services.home-assistant.config = {
    homeassistant = {
      name = "Home";
      temperature_unit = "C";
      unit_system = "metric";
      time_zone = "Europe/Amsterdam";
    };
    frontend = { };
    http = {
      server_host = [ "127.0.0.1" ];
      use_x_forwarded_for = true;
      trusted_proxies = [ "127.0.0.1" ];
    };
  };

  services.nginx.virtualHosts."home.matrss.de" = {
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
      proxyPass = "http://127.0.0.1:8123";
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
}
