{
  virtualisation.oci-containers.containers.traefik-reverse-proxy = {
    image = "traefik:latest";

    ports = [
      "0.0.0.0:80:80"
      "0.0.0.0:443:443"
      "0.0.0.0:8080:8080"
    ];

    volumes = [
      "${./traefik.toml}:/etc/traefik/traefik.toml:ro"
      "/volumes/traefik-letsencrypt:/letsencrypt:rw"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];

    extraOptions = [
      "--net=services"
      # This mapping is necessary for containers in host networking mode
      "--add-host=host.docker.internal:172.17.0.1"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8080 ];
}
