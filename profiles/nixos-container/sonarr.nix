{ config, ... }:

{
  containers.sonarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.20";
    localAddress = "10.11.1.20";
    bindMounts = {
      "${config.containers.sonarr.config.services.sonarr.dataDir}" = { hostPath = "/srv/data/sonarr/config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      services.sonarr.enable = true;
      networking.firewall.allowedTCPPorts = [ 8989 ];
      system.stateVersion = "21.11";
    };
  };
}
