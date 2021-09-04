{ config, ... }:

{
  containers.jellyfin = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.30";
    localAddress = "10.11.1.30";
    bindMounts = {
      "/var/lib/jellyfin" = { hostPath = "/volumes/jellyfin-config"; isReadOnly = false; };
      "/var/cache/jellyfin" = { hostPath = "/volumes/jellyfin-cache"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = true; };
    };
    config = {
      services.jellyfin.enable = true;
      networking.firewall.allowedTCPPorts = [ 8096 ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.jellyfin = {
      rule = "Host(`jellyfin.ara.matrss.de`)";
      entryPoints = [ "websecure" ];
      middlewares = [ "secured" ];
      service = "jellyfin";
    };
    services.jellyfin.loadBalancer.servers = [{ url = "http://${config.containers.jellyfin.localAddress}:8096"; }];
  };
}
