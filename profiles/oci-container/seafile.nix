{
  virtualisation.oci-containers.containers.seafile-mariadb = {
    image = "mariadb:10.6.4";

    environment = {
    };

    volumes = [ "/volumes/seafile-db:/var/lib/mysql:rw" ];

    extraOptions = [
      "--network=web"
    ];
  };

  virtualisation.oci-containers.containers.seafile-memcached = {
    image = "memcached:1.6.10";

    extraOptions = [
      "--network=web"
    ];
  };

  virtualisation.oci-containers.containers.seafile = {
    image = "seafileltd/seafile-mc:8.0.7";

    dependsOn = [ "seafile-mariadb" "seafile-memcached" ];

    environment = {
      DB_HOST = "seafile-mariadb";
      SEAFILE_SERVER_LETSENCRYPT = "false";
      SEAFILE_SERVER_HOSTNAME = "seafile.ara.matrss.de";
    };

    volumes = [ "/volumes/seafile-data:/shared:rw" ];

    extraOptions = [
      "--network=web"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.seafile.rule=Host(`seafile.ara.matrss.de`)"
      "--label=traefik.http.routers.seafile.entrypoints=websecure"
      "--label=traefik.http.routers.seafile.middlewares=public_no-csp@file"
    ];
  };
}
