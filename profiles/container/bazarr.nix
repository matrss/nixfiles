let
  hostPort = 6767;
  containerPort = 6767;
in {
  virtualisation.oci-containers.containers.bazarr = {
    image = "linuxserver/bazarr:latest";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [ "/volumes/bazarr-config:/config" "/srv/media:/media" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.bazarr.rule=Host(`bazarr.ara.matrss.de`)"
      "--label=traefik.http.routers.bazarr.entrypoints=websecure"
      "--label=traefik.http.routers.bazarr.middlewares=authelia@docker"
    ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
