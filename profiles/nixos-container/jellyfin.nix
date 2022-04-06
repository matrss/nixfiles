{ config, ... }:

{
  containers.jellyfin = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.30";
    localAddress = "10.11.1.30";
    bindMounts = {
      "/var/lib/jellyfin" = { hostPath = "/srv/data/jellyfin/config"; isReadOnly = false; };
      "/var/cache/jellyfin" = { hostPath = "/srv/data/jellyfin/cache"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = true; };
    };
    config = {
      services.jellyfin.enable = true;
      networking.firewall.allowedTCPPorts = [ 8096 ];
      system.stateVersion = "21.11";
    };
  };
}
