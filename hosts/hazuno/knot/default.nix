{ config, pkgs, ... }:

{
  sops.secrets."knot-keys.conf" = {
    owner = "knot";
  };

  services.knot = {
    enable = true;
    keyFiles = [ config.sops.secrets."knot-keys.conf".path ];
    extraConfig = ''
      server:
        listen: 10.0.0.54@53
        listen: 2603:c020:800b:fd00:2b10:e461:ff1e:d3e9@53

      remote:
        - id: 1984_ip4
          address: 93.95.224.6

      acl:
        - id: 1984_transfer_acl
          address: 93.95.224.6
          action: transfer

        - id: nelvte_update_acl
          key: nelvte
          action: update
          update-type: [ A, AAAA ]
          update-owner: name
          update-owner-name: [ nelvte.m.matrss.de. ]
          update-owner-match: equal

      mod-rrl:
        - id: default
          rate-limit: 200   # Allow 200 resp/s for each flow
          slip: 2           # Every other response slips

      template:
        - id: default
          semantic-checks: on
          global-module: mod-rrl/default
          zonefile-sync: -1
          zonefile-load: difference
          journal-content: changes

      zone:
        - domain: matrss.de
          file: "${./matrss.de.zone}"
          notify: [ 1984_ip4 ]
          acl: [ 1984_transfer_acl, nelvte_update_acl ]
    '';
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
