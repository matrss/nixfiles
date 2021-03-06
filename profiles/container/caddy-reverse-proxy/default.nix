{
  virtualisation.oci-containers.containers.caddy-reverse-proxy = {
    image = "caddy:latest";

    ports = [ "0.0.0.0:80:80" "0.0.0.0:443:443" ];

    volumes = [ "${./Caddyfile}:/etc/caddy/Caddyfile:ro" ];

    extraOptions = [ "--net=services" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
