{ config, ... }:

{
  sops.secrets.acme-dns-env-matrss_de = { };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "matthias.risze@t-online.de";

  security.acme.certs."nelvte.matrss.de" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme-dns-env-matrss_de.path;
    extraDomainNames = [
      "idp.matrss.de"
      "cloud.matrss.de"
      "media.matrss.de"
      "radarr.matrss.de"
      "sonarr.matrss.de"
      "bazarr.matrss.de"
    ];
  };

  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];
}
