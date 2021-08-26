{
  virtualisation.oci-containers.containers.whoami = {
    image = "containous/whoami:v1.5.0";

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.whoami.rule=Host(`whoami.ara.matrss.de`)"
      "--label=traefik.http.routers.whoami.entrypoints=websecure"
      "--label=traefik.http.routers.whoami.middlewares=secured@file"
    ];
  };
}