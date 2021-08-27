{
  virtualisation.oci-containers.containers.radarr = {
    image = "linuxserver/radarr:version-3.2.2.5080";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    volumes = [ "/volumes/radarr-config:/config" "/srv/media:/media" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.radarr.rule=Host(`radarr.ara.matrss.de`)"
      "--label=traefik.http.routers.radarr.entrypoints=websecure"
      "--label=traefik.http.routers.radarr.middlewares=secured@file"
    ];
  };
}
