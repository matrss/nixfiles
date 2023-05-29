{ config, ... }:

{
  sops.secrets.acme-dns-env = { };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "matthias.risze@t-online.de";
  security.acme.defaults.dnsResolver = "1.1.1.1:53";

  security.acme.certs."hazuno.m.0px.xyz" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme-dns-env.path;
    extraDomainNames = [
      "dns.0px.xyz"
    ];
  };

  users.users.nginx.extraGroups = [ config.users.groups.acme.name ];
}
