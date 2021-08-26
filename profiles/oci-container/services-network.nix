{ pkgs, config, ... }:

{
  systemd.services.init-services-network = {
    description = "Create the network bridge services for hosted services.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig =
      let dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in
      {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.bash}/bin/sh -c "${dockercli} network create services || true"
        '';
        ExecStop = ''
          ${pkgs.bash}/bin/sh -c "${dockercli} network rm services || true"
        '';
      };
  };
}
