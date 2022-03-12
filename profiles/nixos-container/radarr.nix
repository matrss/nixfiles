{ config, lib, ... }:

{
  containers.radarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.21";
    localAddress = "10.11.1.21";
    bindMounts = {
      "${config.containers.radarr.config.services.radarr.dataDir}" = { hostPath = "/srv/data/radarr/config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      services.radarr.enable = true;
      ids.uids.radarr = lib.mkForce 1000;
      users.users.radarr.isSystemUser = true;
      networking.firewall.allowedTCPPorts = [ 7878 ];
      system.stateVersion = "21.11";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.radarr = {
      rule = "Host(`radarr.ara.matrss.de`)";
      entryPoints = [ "websecure" ];
      middlewares = [ "secured_style-src-unsafe-inline" ];
      service = "radarr";
    };
    services.radarr.loadBalancer.servers = [{ url = "http://${config.containers.radarr.localAddress}:7878"; }];
  };
}
