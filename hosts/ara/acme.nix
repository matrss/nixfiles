{ config, ... }:

{
  sops.secrets.acme-dns-env-matrss_de = { };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "matthias.risze@t-online.de";

  security.acme.certs."ara.matrss.de" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme-dns-env-matrss_de.path;
    extraDomainNames = [
      "idp.ara.matrss.de"
      "nextcloud.ara.matrss.de"
      "jellyfin.ara.matrss.de"
      "radarr.ara.matrss.de"
      "sonarr.ara.matrss.de"
    ];
  };

  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];
}
