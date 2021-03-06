let
  hostPort = 8889;
  containerPort = 80;
in {
  virtualisation.oci-containers.containers.hello-world = {
    image = "tutum/hello-world:latest";

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.hello-world.rule=Host(`hello-world.ara.matrss.de`)"
      "--label=traefik.http.routers.hello-world.entrypoints=websecure"
      # "--label=traefik.http.routers.hello-world.tls=true"
      # "--label=traefik.http.routers.hello-world.tls.certresolver=myresolver"
    ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
