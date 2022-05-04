{ config, ... }:

{
  sops.secrets.acme-dns-env-matrss_de = { };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "matthias.risze@t-online.de";

  security.acme.certs."nelvte.matrss.de" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme-dns-env-matrss_de.path;
    extraDomainNames = [
      "idp.nelvte.matrss.de"
      "nextcloud.nelvte.matrss.de"
      "jellyfin.nelvte.matrss.de"
      "radarr.nelvte.matrss.de"
      "sonarr.nelvte.matrss.de"
      "bazarr.nelvte.matrss.de"
    ];
  };

  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];
}
