{ inputs, ... }:

{
  containers.mpanra = {
    autoStart = true;
    ephemeral = true;
    macvlans = [
      "enp0s25"
    ];
    bindMounts = {
      "/var/lib" = {
        hostPath = "/data/mpanra-varlib";
        isReadOnly = false;
      };
      "/media" = {
        hostPath = "/data/media";
        isReadOnly = false;
      };
    };
    config = {
      imports = [
        inputs.sops-nix.nixosModules.sops
        ./acme.nix
        ./bazarr.nix
        ./buildbot
        ./cloudflare-dyndns.nix
        ./home-assistant.nix
        ./jellyfin.nix
        ./kanidm.nix
        ./nextcloud.nix
        ./nginx.nix
        ./postgresql.nix
        ./radarr.nix
        ./sonarr.nix
        ./tiddlywiki.nix
      ];

      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.defaultSopsFile = ../../../secrets/mpanra/secrets.yaml;
      networking.useDHCP = false;
      networking.interfaces.mv-enp0s25.useDHCP = true;

      system.stateVersion = "20.09";
    };
  };
}
