{ config, ... }:

{
  systemd.services.kanidm.serviceConfig = {
    SupplementaryGroups = [ config.users.groups.acme.name ];
    BindReadOnlyPaths = [ config.security.acme.certs."nelvte.m.matrss.xyz".directory ];
  };

  services.kanidm = {
    enableClient = true;
    clientSettings = {
      uri = "https://idm.matrss.xyz";
    };
    enableServer = true;
    serverSettings = {
      domain = "matrss.xyz";
      origin = "https://idm.matrss.xyz";
      bindaddress = "127.0.0.1:8888";
      ldapbindaddress = "127.0.0.1:636";
      tls_chain = "${config.security.acme.certs."nelvte.m.matrss.xyz".directory}/fullchain.pem";
      tls_key = "${config.security.acme.certs."nelvte.m.matrss.xyz".directory}/key.pem";
    };
  };

  services.nginx.virtualHosts."idm.matrss.xyz" = {
    forceSSL = true;
    useACMEHost = "nelvte.m.matrss.xyz";
    locations."/" = {
      proxyPass = "https://127.0.0.1:8888";
      proxyWebsockets = true;
    };
  };
}
