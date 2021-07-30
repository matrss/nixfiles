{
  virtualisation.oci-containers.containers.filestash = {
    image = "machines/filestash:latest";

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.filestash.rule=Host(`filestash.ara.matrss.de`)"
      "--label=traefik.http.routers.filestash.entrypoints=websecure"
      "--label=traefik.http.routers.filestash.middlewares=secured@file"
    ];
  };
}
