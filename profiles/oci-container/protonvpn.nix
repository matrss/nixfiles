{ pkgs, config, ... }:

{
  sops.secrets.protonvpn-env = { };

  virtualisation.oci-containers.containers.protonvpn = {
    image = "ghcr.io/tprasadtp/protonvpn:4.2.1";

    environment = {
      PROTONVPN_TIER = "0";
      PROTONVPN_COUNTRY = "NL";
      PROTONVPN_EXCLUDE_CIDRS = "10.1.1.0/24";
    };

    volumes = [ "/dev/net:/dev/net:z" ];

    extraOptions = [
      "--env-file=${config.sops.secrets.protonvpn-env.path}"
      "--cap-add=NET_ADMIN"
      "--net=proton_network"
      "--ip=10.1.1.2"
      "--dns=1.1.1.1"
    ];
  };

  systemd.services.init-protonvpn-network = {
    description =
      "Create the network bridge proton_network for protonvpn proxied services.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig =
      let dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in
      {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.bash}/bin/sh -c "${dockercli} network create --subnet 10.1.1.0/24 --gateway 10.1.1.1 proton_network || true"
        '';
        ExecStop = ''
          ${pkgs.bash}/bin/sh -c "${dockercli} network rm proton_network || true"
        '';
      };
  };
}
