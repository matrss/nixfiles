{
  # imports = [ ./protonvpn.nix ];

  virtualisation.oci-containers.containers = {
    rotating-proxy = {
      image = "mattes/rotating-proxy:latest";

      # dependsOn = [ "protonvpn" ];

      environment = { tors = "25"; };

      ports = [ "5566:5566" "4444:4444" ];

      # extraOptions = [ "--net=container:protonvpn" ];
    };

    # rotating-proxy-revproxy = {
    #   image = "caddy:2.0.0";
    #   dependsOn = [ "rotating-proxy" ];
    #   ports = [ "5566:5566" "4444:4444" ];
    #   cmd = [
    #     "caddy"
    #     "reverse-proxy"
    #     "--from"
    #     ":5566"
    #     "--to"
    #     "10.1.1.2:5566"
    #     # "--from"
    #     # ":4444"
    #     # "--to"
    #     # "10.1.1.2:4444"
    #   ];
    #   extraOptions = [ "--net=proton_network" ];
    # };
  };

  networking.firewall.allowedTCPPorts = [ 5566 4444 ];
}
