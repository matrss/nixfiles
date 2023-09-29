{
  services.uptime-kuma.enable = true;

  services.nginx.virtualHosts."status.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "hazuno.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };
}
