{ config, ... }:

{
  containers.sonarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.20";
    localAddress = "10.11.1.20";
    bindMounts = {
      "${config.containers.sonarr.config.services.sonarr.dataDir}" = { hostPath = "/volumes/sonarr-config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      services.sonarr.enable = true;
      networking.firewall.allowedTCPPorts = [ 8989 ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.sonarr = {
      rule = "Host(`sonarr.ara.matrss.de`)";
      entryPoints = [ "websecure" ];
      middlewares = [ "secured" ];
      service = "sonarr";
    };
    services.sonarr.loadBalancer.servers = [ { url = "http://${config.containers.sonarr.localAddress}:8989"; } ];
  };
}
