{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  virtualisation.oci-containers.containers.traefik = {
    image = "traefik:v2.5.1";

    ports = [ "0.0.0.0:80:80" "0.0.0.0:443:443" ];

    volumes = [
      "${./static-config.toml}:/etc/traefik/traefik.toml:ro"
      "${./dynamic-config}:/etc/traefik/dynamic-config:ro"
      "/volumes/traefik-data:/data:rw"
    ];

    extraOptions = [
      "--network=web"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.api.rule=Host(`traefik.ara.matrss.de`)"
      "--label=traefik.http.routers.api.entrypoints=websecure"
      "--label=traefik.http.routers.api.service=api@internal"
      "--label=traefik.http.routers.api.middlewares=secured@file"
      # This mapping is necessary for containers in host networking mode
      "--add-host=host.docker.internal:172.17.0.1"
    ];
  };

  virtualisation.oci-containers.containers.traefik-docker-socket-proxy = {
    image = "tecnativa/docker-socket-proxy:0.1.1";

    environment.CONTAINERS = "1";

    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];

    extraOptions = [
      "--network=web"
    ];
  };

  systemd.services.init-web-network = {
    description = "Create a network bridge named web for exposed services.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig =
      let executable =
        if config.virtualisation.oci-containers.backend == "docker" then "${config.virtualisation.docker.package}/bin/docker"
        else if config.virtualisation.oci-containers.backend == "podman" then "${config.virtualisation.podman.package}/bin/podman"
        else throw "Unhandled backend: ${config.virtualisation.oci-containers.backend}";
      in
      {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.bash}/bin/sh -c "${executable} network create --driver bridge web || true"
        '';
        ExecStop = ''
          ${pkgs.bash}/bin/sh -c "${executable} network rm services || true"
        '';
      };
  };
}
