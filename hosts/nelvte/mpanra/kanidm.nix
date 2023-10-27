{ config, ... }:

{
  systemd.services.kanidm.serviceConfig = {
    SupplementaryGroups = [ config.users.groups.acme.name ];
    BindReadOnlyPaths = [ config.security.acme.certs."mpanra.m.0px.xyz".directory ];
  };

  services.kanidm = {
    enableClient = true;
    clientSettings = {
      uri = "https://idm.0px.xyz";
    };
    enableServer = true;
    serverSettings = {
      domain = "idm.0px.xyz";
      origin = "https://idm.0px.xyz";
      bindaddress = "127.0.0.1:8888";
      ldapbindaddress = "127.0.0.1:636";
      tls_chain = "${config.security.acme.certs."mpanra.m.0px.xyz".directory}/fullchain.pem";
      tls_key = "${config.security.acme.certs."mpanra.m.0px.xyz".directory}/key.pem";
    };
  };

  services.nginx.virtualHosts."idm.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "mpanra.m.0px.xyz";
    locations."/" = {
      proxyPass = "https://127.0.0.1:8888";
      proxyWebsockets = true;
    };
  };
}
