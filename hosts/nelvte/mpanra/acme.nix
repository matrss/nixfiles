{ config, ... }:

{
  sops.secrets.acme-dns-env = { };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "matthias.risze@t-online.de";
  security.acme.defaults.dnsResolver = "1.1.1.1:53";

  security.acme.certs."mpanra.m.0px.xyz" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme-dns-env.path;
    extraDomainNames = [
      "cloud.0px.xyz"
      "home.0px.xyz"
      "idm.0px.xyz"
      "nix-cache.0px.xyz"
      "status.0px.xyz"
      "paperless.0px.xyz"
      "wiki.0px.xyz"
    ];
  };

  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];
}
