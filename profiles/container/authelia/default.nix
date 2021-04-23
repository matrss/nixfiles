{ config, ... }:

{
  sops.secrets = {
    authelia-jwt-secret = { };
    authelia-session-secret = { };
    authelia-notifier-smtp-password = { };
  };

  virtualisation.oci-containers.containers.authelia = {
    image = "authelia/authelia:4.27.4";

    environment = {
      AUTHELIA_JWT_SECRET_FILE = "${config.sops.secrets.authelia-jwt-secret.path}";
      AUTHELIA_SESSION_SECRET_FILE = "${config.sops.secrets.authelia-session-secret.path}";
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = "${config.sops.secrets.authelia-notifier-smtp-password.path}";
    };

    volumes = [
      "${config.sops.secrets.authelia-jwt-secret.path}:${config.sops.secrets.authelia-jwt-secret.path}:ro"
      "${config.sops.secrets.authelia-session-secret.path}:${config.sops.secrets.authelia-session-secret.path}:ro"
      "${config.sops.secrets.authelia-notifier-smtp-password.path}:${config.sops.secrets.authelia-notifier-smtp-password.path}:ro"
      "${./configuration.yml}:/configuration.yml:ro"
      "/volumes/authelia-config:/config:rw"
    ];

    cmd = [ "--config" "/configuration.yml" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.authelia.rule=Host(`auth.ara.matrss.de`)"
      "--label=traefik.http.routers.authelia.entrypoints=websecure"
      "--label=traefik.http.routers.authelia.middlewares=public@file"
    ];
  };
}