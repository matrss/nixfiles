{
  imports = [ ./protonvpn.nix ];

  virtualisation.oci-containers.containers = {
    jdownloader = {
      image = "jlesage/jdownloader-2:v1.7.0";

      dependsOn = [ "protonvpn" ];

      environment = {
        USER_ID = "1000";
        GROUP_ID = "100";
      };

      volumes = [
        "/volumes/jdownloader-config:/config:rw"
        "/srv/media/Downloads/jdownloader2:/output:rw"
        "/etc/localtime:/etc/localtime:ro"
      ];

      extraOptions = [ "--net=container:protonvpn" ];
    };

    jdown-revproxy = {
      image = "caddy:2.3.0-alpine";
      dependsOn = [ "jdownloader" ];
      ports = [ "5800:5800" ];
      cmd = [
        "caddy"
        "reverse-proxy"
        "--change-host-header"
        "--from"
        ":5800"
        "--to"
        "10.1.1.2:5800"
      ];
      extraOptions = [ "--net=proton_network" ];
    };
  };

  # networking.firewall.allowedTCPPorts = [ 3129 5800 ];
  networking.firewall.allowedTCPPorts = [ 5800 ];
}
