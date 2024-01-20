{ config, pkgs, ... }:

let
  smtp2paperless_port = 54321;
in
{
  networking.firewall.allowedTCPPorts = [ smtp2paperless_port ];

  systemd.services.smtp2paperless = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "exec";
      DynamicUser = true;
      SupplementaryGroups = [ config.users.groups.acme.name ];
      ExecStart = ''
        ${pkgs.smtp2paperless}/bin/smtp2paperless \
          --host 0 \
          --port ${toString smtp2paperless_port} \
          --cert "${config.security.acme.certs."hazuno.m.0px.xyz".directory}/fullchain.pem" \
          --key "${config.security.acme.certs."hazuno.m.0px.xyz".directory}/key.pem" \
          --allowed_domains paperless.0px.xyz
      '';
    };
  };
}
