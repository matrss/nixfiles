let
  hostPort = 8989;
  containerPort = 8989;
in {
  virtualisation.oci-containers.containers.sonarr = {
    image = "linuxserver/sonarr:preview-version-3.0.5.1143";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [
      "/volumes/sonarr-config:/config"
      "/srv/media:/media"
    ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.sonarr.rule=Host(`sonarr.ara.matrss.de`)"
      "--label=traefik.http.routers.sonarr.entrypoints=websecure"
      "--label=traefik.http.routers.sonarr.middlewares=secured@file"
    ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
