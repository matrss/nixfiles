{ lib, config, ... }:

{
  containers.bazarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.22";
    localAddress = "10.11.1.22";
    bindMounts = {
      "${config.containers.bazarr.config.users.users.bazarr.home}" = { hostPath = "/volumes/bazarr-config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
      ];
      services.bazarr.enable = true;
      networking.firewall.allowedTCPPorts = [ 6767 ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.bazarr = {
      rule = "Host(`bazarr.ara.matrss.de`)";
      entryPoints = [ "websecure" ];
      middlewares = [ "secured" ];
      service = "bazarr";
    };
    services.bazarr.loadBalancer.servers = [ { url = "http://${config.containers.bazarr.localAddress}:6767"; } ];
  };
}
