{ config, ... }:

{
  sops.secrets.acme-dns-env-matrss_xyz = { };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "matthias.risze@t-online.de";

  security.acme.certs."nelvte.matrss.xyz" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme-dns-env-matrss_xyz.path;
    extraDomainNames = [
      "bazarr.matrss.xyz"
      "cloud.matrss.xyz"
      "home.matrss.xyz"
      "hydra.matrss.xyz"
      "idp.matrss.xyz"
      "media.matrss.xyz"
      "radarr.matrss.xyz"
      "sonarr.matrss.xyz"
      "wiki.matrss.xyz"
    ];
  };

  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];
}
