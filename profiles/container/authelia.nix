{
  virtualisation.oci-containers.containers.authelia = {
    image = "authelia/authelia";

    volumes = [
      "${../../secrets/hosts/ara/authelia/configuration.yml}:/configuration.yml:ro"
      "/volumes/authelia-config:/config:rw"
    ];

    cmd = [
      "--config" "/configuration.yml"
    ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.authelia.rule=Host(`auth.ara.matrss.de`)"
      "--label=traefik.http.routers.authelia.entrypoints=websecure"
      "--label=traefik.http.routers.authelia.middlewares=public@file"
    ];
  };
}
