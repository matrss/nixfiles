{ config, ... }:

{
  containers.radarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.21";
    localAddress = "10.11.1.21";
    bindMounts = {
      "${config.containers.radarr.config.services.radarr.dataDir}" = { hostPath = "/volumes/radarr-config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      services.radarr.enable = true;
      networking.firewall.allowedTCPPorts = [ 7878 ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.radarr = {
      rule = "Host(`radarr.ara.matrss.de`)";
      entryPoints = [ "websecure" ];
      middlewares = [ "secured" ];
      service = "radarr";
    };
    services.radarr.loadBalancer.servers = [{ url = "http://${config.containers.radarr.localAddress}:7878"; }];
  };
}
