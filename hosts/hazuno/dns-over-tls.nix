{ config, ... }:

{
  networking.firewall.allowedTCPPorts = [ 853 ];

  services.nginx.streamConfig = ''
    upstream dns-servers {
        server 127.0.0.1:53;
    }

    server {
        listen 853 ssl;
        proxy_pass dns-servers;

        ssl_certificate ${config.security.acme.certs."hazuno.m.0px.xyz".directory}/fullchain.pem;
        ssl_certificate_key ${config.security.acme.certs."hazuno.m.0px.xyz".directory}/key.pem;
    }
  '';
}
