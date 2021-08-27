{
  virtualisation.oci-containers.containers.sonarr = {
    image = "linuxserver/sonarr:version-3.0.6.1265";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    volumes = [ "/volumes/sonarr-config:/config" "/srv/media:/media" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.sonarr.rule=Host(`sonarr.ara.matrss.de`)"
      "--label=traefik.http.routers.sonarr.entrypoints=websecure"
      "--label=traefik.http.routers.sonarr.middlewares=secured@file"
    ];
  };
}
