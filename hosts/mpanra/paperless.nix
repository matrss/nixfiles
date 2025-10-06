{ config, ... }:

{
  services.paperless.enable = true;
  services.paperless.address = "127.0.0.1";
  services.paperless.settings = {
    PAPERLESS_URL = "https://paperless.0px.xyz";
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
    PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
    PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";
    PAPERLESS_CONSUMER_BARCODE_UPSCALE = 1.5;
    PAPERLESS_CONSUMER_BARCODE_DPI = 600;
    # Required for some documents, see: https://docs.paperless-ngx.com/troubleshooting/#consumption-fails-with-ghostscript-pdfa-rendering-failed
    PAPERLESS_OCR_USER_ARGS = {
      continue_on_soft_render_error = true;
    };
  };

  services.nginx.virtualHosts."paperless.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "mpanra.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://${config.services.paperless.address}:${toString config.services.paperless.port}";
    };
  };

  environment.etc."fail2ban/filter.d/paperless.local".text = ''
    [Definition]
    failregex = Login failed for user `.*` from (?:IP|private IP) `<HOST>`\.$
    ignoreregex =
  '';

  services.fail2ban.jails.paperless.settings = {
    filter = "paperless";
    journalmatch = "_SYSTEMD_UNIT=paperless-web.service";
  };
}
