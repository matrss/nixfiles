let
  hostPort = 3000;
  containerPort = 3000;
in {
  virtualisation.oci-containers.containers.gin = {
    image = "gnode/gin-web";

    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Europe/Berlin";
    };

    ports =
      [ "0.0.0.0:${toString hostPort}:${toString containerPort}" "2323:22" ];

    volumes = [ "/volumes/gin-data:/data" "/volumes/gin-backup:/backup" ];

    extraOptions = [ "--net=services" ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort 2323 ];
}
