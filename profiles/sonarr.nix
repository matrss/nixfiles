let
  hostPort = 8989;
  containerPort = 8989;
in {
  virtualisation.oci-containers.containers.sonarr = {
    image = "linuxserver/sonarr:preview-version-3.0.4.1120";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [
      "sonarr-config:/config"
      "/srv/media:/media"
      # "/srv/media/Downloads:/downloads"
      # "/srv/media/Series:/tv"
    ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
