{
  virtualisation.oci-containers.containers.bazarr = {
    image = "linuxserver/bazarr:version-v0.9.7";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    volumes = [ "/volumes/bazarr-config:/config" "/srv/media:/media" ];

    extraOptions = [
      "--network=web"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.bazarr.rule=Host(`bazarr.ara.matrss.de`)"
      "--label=traefik.http.routers.bazarr.entrypoints=websecure"
      "--label=traefik.http.routers.bazarr.middlewares=secured@file"
      # "--label=traefik.http.routers.bazarr.middlewares.secure-headers.contentSecurityPolicy=\"script-src 'unsafe-inline'\""
    ];
  };
}
