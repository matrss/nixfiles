{ config, ... }:

{
  sops.secrets."paperless/secret-env" = { };

  services.paperless.enable = true;
  services.paperless.address = "127.0.0.1";
  services.paperless.extraConfig = {
    PAPERLESS_URL = "https://paperless.0px.xyz";
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    # Required for some documents, see: https://docs.paperless-ngx.com/troubleshooting/#consumption-fails-with-ghostscript-pdfa-rendering-failed
    PAPERLESS_OCR_USER_ARGS = "{\"continue_on_soft_render_error\": true}";
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
