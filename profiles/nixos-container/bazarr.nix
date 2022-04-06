{ lib, config, ... }:

{
  containers.bazarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.11.0.22";
    localAddress = "10.11.1.22";
    bindMounts = {
      "/var/lib/bazarr" = { hostPath = "/srv/data/bazarr/config"; isReadOnly = false; };
      "/media" = { hostPath = "/srv/media"; isReadOnly = false; };
    };
    config = {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
      ];
      services.bazarr.enable = true;
      networking.firewall.allowedTCPPorts = [ 6767 ];
      system.stateVersion = "21.11";
    };
  };
}
