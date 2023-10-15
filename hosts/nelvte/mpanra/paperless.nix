{ config, ... }:

{
  sops.secrets."paperless/secret-env" = { };

  services.paperless.enable = true;
  services.paperless.address = "127.0.0.1";
  services.paperless.extraConfig = {
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
  };

  systemd.services.paperless-web.serviceConfig.EnvironmentFile = config.sops.secrets."paperless/secret-env".path;

  services.nginx.virtualHosts."paperless.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "mpanra.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://${config.services.paperless.address}:${toString config.services.paperless.port}";
    };
  };
}
