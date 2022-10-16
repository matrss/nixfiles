{ config, ... }:

{
  sops.secrets."cloudflare-dyndns/api-token" = { };

  services.cloudflare-dyndns = {
    enable = true;
    domains = [ "nelvte.matrss.xyz" ];
    proxied = false;
    ipv4 = true;
    ipv6 = true;
    deleteMissing = true;
    apiTokenFile = config.sops.secrets."cloudflare-dyndns/api-token".path;
  };
}
