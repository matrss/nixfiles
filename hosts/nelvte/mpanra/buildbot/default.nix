{ config, pkgs, ... }:

{
  sops.secrets."buildbot/users" = { };

  nix.settings.allowed-users = [ config.services.buildbot-master.user ];

  services.buildbot-master = {
    enable = true;
    home = "/var/lib/buildbot";
    masterCfg = "${./.}/master.py";
    pythonPackages = ps: [
      (ps.toPythonModule pkgs.buildbot-worker)
    ];
  };

  systemd.services.buildbot-master = {
    path = [
      pkgs.nix
    ];
    serviceConfig.LoadCredential = [
      "users:${config.sops.secrets."buildbot/users".path}"
    ];
  };

  services.nginx.virtualHosts."buildbot.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "mpanra.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8010";
      proxyWebsockets = true;
    };
  };
}
