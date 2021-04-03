{
  imports = [ ./protonvpn.nix ];

  virtualisation.oci-containers.containers = {
    pyload = {
      image = "linuxserver/pyload:version-4b905ceb";

      dependsOn = [ "protonvpn" ];

      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Europe/Berlin";
      };

      volumes = [
        "/volumes/pyload-config:/config:rw"
        "/srv/media/Downloads/pyload:/downloads:rw"
      ];

      extraOptions = [ "--net=container:protonvpn" ];
    };

    pyload-revproxy = {
      image = "caddy:2.3.0-alpine";
      dependsOn = [ "pyload" ];
      ports = [ "8000:8000" ];
      cmd = [
        "caddy"
        "reverse-proxy"
        "--from"
        ":8000"
        "--to"
        "10.1.1.2:8000"
      ];
      extraOptions = [ "--net=proton_network" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8000 ];
}
