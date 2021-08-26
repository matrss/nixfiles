{ config, ... }:

{
  virtualisation.oci-containers.containers.vaultwarden = {
    image = "vaultwarden/server:1.22.2";

    # TODO: run container as another user
    # user = "${config.users.users.vaultwarden.uid}:${config.users.users.vaultwarden.gid}";

    volumes = [ "/volumes/vaultwarden-data:/data:rw" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.vaultwarden.rule=Host(`vaultwarden.ara.matrss.de`)"
      "--label=traefik.http.routers.vaultwarden.entrypoints=websecure"
      "--label=traefik.http.routers.vaultwarden.middlewares=secured@file"
    ];
  };

  # users.users.vaultwarden = {
  #   isSystemUser = true;
  #   group = "vaultwarden";
  # };

  # users.groups.vaultwarden = { };
}
