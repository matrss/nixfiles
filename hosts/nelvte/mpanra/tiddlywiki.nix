{ config, lib, ... }:

{
  sops.secrets."tiddlywiki/credentials" = { };

  services.tiddlywiki.enable = true;
  services.tiddlywiki.listenOptions = {
    readers = "(anon)";
    writers = "(authenticated)";
    admin = "matrss";
    credentials = "/run/credentials/tiddlywiki.service/credentials";
    host = "127.0.0.1";
    port = "8080";
  };

  systemd.services.tiddlywiki.serviceConfig.LoadCredential =
    "credentials:${config.sops.secrets."tiddlywiki/credentials".path}";

  services.nginx.virtualHosts."wiki.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "mpanra.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
    };
  };
}
