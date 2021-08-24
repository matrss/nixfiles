{
  # On first install it is necessary to create a superuser account
  # via `python manage.py createsuperuser`
  virtualisation.oci-containers.containers.paperless-ng = {
    image = "jonaswinkler/paperless-ng:1.4.1";

    environment = {
      USERMAP_UID = "1000";
      USERMAP_GID = "100";
      PAPERLESS_OCR_LANGUAGE = "deu";
      PAPERLESS_OCR_LANGUAGES = "eng deu";
      PAPERLESS_TIME_ZONE = "Europe/Berlin";
    };

    ports = [ "8444:8000" ];

    volumes = [ "/volumes/paperless-ng-data:/usr/src/paperless/data" "/volumes/paperless-ng-media:/usr/src/paperless/media" "/volumes/paperless-ng-export:/usr/src/paperless/export" "/volumes/paperless-ng-consume:/usr/src/paperless/consume" ];

    extraOptions = [
      "--net=services"
      # "--label=traefik.enable=true"
      # "--label=traefik.http.routers.sonarr.rule=Host(`sonarr.ara.matrss.de`)"
      # "--label=traefik.http.routers.sonarr.entrypoints=websecure"
      # "--label=traefik.http.routers.sonarr.middlewares=secured@file"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8444 ];
}
