{
  virtualisation.oci-containers.containers.cells-mariadb = {
    image = "mariadb:10.7.1";

    environment = {
      MYSQL_DATABASE = "cells";
      MYSQL_USER = "pydio";
    };

    volumes = [ "/volumes/cells-db:/var/lib/mysql:rw" ];

    extraOptions = [
      "--network=web"
    ];
  };

  virtualisation.oci-containers.containers.cells = {
    image = "pydio/cells:3.0.1";

    dependsOn = [ "cells-mariadb" ];

    environment = {
      CELLS_NO_TLS = "1";
      CELLS_EXTERNAL = "https://cells.ara.matrss.de";
    };

    volumes = [ "/volumes/cells-dir:/var/cells:rw" "/volumes/cells-data:/var/cells/data:rw" ];

    extraOptions = [
      "--network=web"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.cells.rule=Host(`cells.ara.matrss.de`)"
      "--label=traefik.http.routers.cells.entrypoints=websecure"
      "--label=traefik.http.routers.cells.middlewares=public_no-csp@file"
      "--label=traefik.http.services.cells.loadbalancer.server.port=8080"
    ];
  };
}
