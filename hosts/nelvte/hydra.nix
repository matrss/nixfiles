{ config, lib, ... }:

{
  sops.secrets."hydra/secret-key" = {
    inherit (config.users.users.hydra-www) group;
    mode = "0440";
  };

  sops.secrets."hydra/gitlab-token/matrss/nixfiles" = {
    inherit (config.users.users.hydra-www) group;
    mode = "0440";
  };

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.0px.xyz";
    notificationSender = "";
    useSubstitutes = true;
    listenHost = "localhost";
    extraConfig = ''
      binary_cache_secret_key_file = ${config.sops.secrets."hydra/secret-key".path}
      Include ${config.sops.secrets."hydra/gitlab-token/matrss/nixfiles".path}
    '';
  };

  services.nginx.virtualHosts."hydra.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "nelvte.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
    };
  };

  # This fixes issues with fetching flake-compat
  # src: https://github.com/NixOS/hydra/issues/1183
  nix.extraOptions = ''
    allowed-uris = https://
  '';

  # nix.buildMachines = [
  #   {
  #     hostName = "localhost";
  #     systems = [ "x86_64-linux" "i686-linux" ];
  #     supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
  #     maxJobs = 8;
  #   }
  # ];
  nix.settings.system-features = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];

  systemd.services.before-restic-backups-local-backup.preStart = lib.mkAfter ''
    systemctl stop \
      hydra-init.service \
      hydra-evaluator.service \
      hydra-notify.service \
      hydra-queue-runner.service \
      hydra-send-stats.service \
      hydra-server.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = lib.mkBefore ''
    systemctl start \
      hydra-init.service \
      hydra-evaluator.service \
      hydra-notify.service \
      hydra-queue-runner.service \
      hydra-send-stats.service \
      hydra-server.service
  '';
}
