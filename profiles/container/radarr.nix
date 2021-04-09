let
  hostPort = 7878;
  containerPort = 7878;
in {
  virtualisation.oci-containers.containers.radarr = {
    image = "linuxserver/radarr:nightly-version-3.1.0.4832";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [ "/volumes/radarr-config:/config" "/srv/media:/media" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.radarr.rule=Host(`radarr.ara.matrss.de`)"
      "--label=traefik.http.routers.radarr.entrypoints=websecure"
      "--label=traefik.http.routers.radarr.middlewares=secured@file"
    ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
