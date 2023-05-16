{ config, pkgs, ... }:

{
  sops.secrets."buildbot/users" = { };
  sops.secrets."buildbot/gitlab-hook-secret" = { };
  sops.secrets."buildbot/gitlab-status-push-token" = { };
  sops.secrets."buildbot/ssh-private-key" = { };

  nix.settings.allowed-users = [ config.services.buildbot-master.user ];

  services.buildbot-master = {
    enable = true;
    home = "/var/lib/buildbot";
    masterCfg = "${./.}/master.py";
    pythonPackages = ps: with ps; [
      (toPythonModule pkgs.buildbot-worker)
      treq
    ];
  };

  systemd.services.buildbot-master = {
    path = [
      pkgs.bash
      pkgs.jq
      pkgs.nix
      pkgs.openssh
    ];
    serviceConfig.LoadCredential = [
      "users:${config.sops.secrets."buildbot/users".path}"
      "gitlab-hook-secret:${config.sops.secrets."buildbot/gitlab-hook-secret".path}"
      "gitlab-status-push-token:${config.sops.secrets."buildbot/gitlab-status-push-token".path}"
      "ssh-private-key:${config.sops.secrets."buildbot/ssh-private-key".path}"
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
