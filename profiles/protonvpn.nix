{
  virtualisation.oci-containers.containers.protonvpn = {
    image = "tprasadtp/protonvpn:latest";

    environment = import ../secrets/protonvpn-env.nix;

    volumes = [ "/dev/net:/dev/net:z" ];

    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--net=proton_network"
      "--ip=10.1.1.2"
      "--dns=1.1.1.1"
    ];

    # image = "qmcgaw/gluetun:latest";

    # environment = import ../secrets/protonvpn-gluetun.nix;

    # volumes = [ "gluetun-config:/gluetun" ];

    # extraOptions = [
    #   "--cap-add=NET_ADMIN"
    #   "--net=proton_network"
    #   "--ip=10.1.1.2"
    # ]
  };
}
