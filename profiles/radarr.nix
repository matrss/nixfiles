let
  hostPort = 7878;
  containerPort = 7878;
in {
  virtualisation.oci-containers.containers.radarr = {
    image = "linuxserver/radarr:nightly-version-3.1.0.4615";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [
      "radarr-config:/config"
      "/srv/media:/media"
      # "/srv/media/Downloads:/downloads"
      # "/srv/media/Movies:/movies"
    ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
