{ pkgs, ... }:

{
  users.users.root.openssh.authorizedKeys.keys =
    let
      restricted-commands-for-deployments = pkgs.writeShellApplication {
        name = "restricted-commands-for-deployments";
        text = ''
          case "$SSH_ORIGINAL_COMMAND" in
            "journalctl --unit nixos-upgrade.service --since "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z)
              exec $SSH_ORIGINAL_COMMAND
              ;;
            "readlink /run/current-system")
              exec $SSH_ORIGINAL_COMMAND
              ;;
            "systemctl start --no-block nixos-upgrade.service")
              exec $SSH_ORIGINAL_COMMAND
              ;;
          esac
          exit 1
        '';
      };
    in
    [
      "command=\"${restricted-commands-for-deployments}/bin/restricted-commands-for-deployments\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAxL0AN/OIueekEBUTvjdJippFSHP0gzooz66rvmLFL GitHub Actions deploy"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByQhPnALCgo9Q4FbqYBCSTbMbP6OuSNmgRafdDo6yAx matrss@ipsmin"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPubsvPoZUNcSgsxMgsjwLoqNJlwEAqm/L1B7yXJBH0x matrss@kayhat"
    ];
}
