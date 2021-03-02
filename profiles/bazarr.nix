let
  hostPort = 6767;
  containerPort = 6767;
in {
  virtualisation.oci-containers.containers.bazarr = {
    image = "linuxserver/bazarr:latest";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [ "bazarr-config:/config" "/srv/media:/media" ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
