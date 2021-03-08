{
  virtualisation.oci-containers.containers.traefik-reverse-proxy = {
    image = "traefik:latest";

    ports = [
      "0.0.0.0:80:80"
      "0.0.0.0:443:443"
    ];

    volumes = [
      "${./static-config.toml}:/etc/traefik/traefik.toml:ro"
      "${./dynamic-config}:/etc/traefik/dynamic-config:ro"
      "/volumes/traefik-data:/data:rw"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.api.rule=Host(`traefik.ara.matrss.de`)"
      "--label=traefik.http.routers.api.entrypoints=websecure"
      "--label=traefik.http.routers.api.service=api@internal"
      "--label=traefik.http.routers.api.middlewares=secured@file"
      # This mapping is necessary for containers in host networking mode
      "--add-host=host.docker.internal:172.17.0.1"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8080 ];
}
