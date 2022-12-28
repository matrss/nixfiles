{ config, ... }:

{
  sops.secrets.acme-dns-env-matrss_xyz = { };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "matthias.risze@t-online.de";

  security.acme.certs."nelvte.m.matrss.xyz" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme-dns-env-matrss_xyz.path;
    extraDomainNames = [
      "cloud.matrss.xyz"
      "home.matrss.xyz"
      "hydra.matrss.xyz"
      "idm.matrss.xyz"
      "status.matrss.xyz"
      "wiki.matrss.xyz"
    ];
  };

  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];
}
