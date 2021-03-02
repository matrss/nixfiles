let
  hostPort = 8383;
  containerPort = 8384;
in {
  virtualisation.oci-containers.containers.syncthing = {
    image = "linuxserver/syncthing:latest";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [ "syncthing-config:/config" "/srv/media:/media" ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
