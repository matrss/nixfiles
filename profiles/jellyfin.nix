let
  hostPort = 8096;
  containerPort = 8096;
in {
  virtualisation.oci-containers.containers.jellyfin = {
    image = "jellyfin/jellyfin:10.7.0-rc4";

    user = "1000:100";

    # ports = [ "0.0.0.0:${toString hostPort}:${toString containerPort}" ];

    volumes = [
      "jellyfin-config:/config"
      "jellyfin-cache:/cache"
      "/srv/media:/media:ro"
    ];

    extraOptions = [ "--network=host" ];
  };

  networking.firewall.allowedTCPPorts = [ hostPort ];
}
