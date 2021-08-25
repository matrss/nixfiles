let
  hostPort = 8096;
  containerPort = 8096;
in
{
  virtualisation.oci-containers.containers.jellyfin = {
    image = "jellyfin/jellyfin:10.7.6";

    user = "1000:100";

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [
      "/volumes/jellyfin-config:/config"
      "/volumes/jellyfin-cache:/cache"
      "/srv/media:/media:ro"
    ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.jellyfin.rule=Host(`jellyfin.ara.matrss.de`)"
      "--label=traefik.http.routers.jellyfin.entrypoints=websecure"
      "--label=traefik.http.routers.jellyfin.middlewares=secured@file"
      "--label=traefik.http.services.jellyfin.loadbalancer.server.port=8096"
    ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
