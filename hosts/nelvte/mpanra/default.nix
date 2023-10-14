{ inputs, ... }:

{
  containers.mpanra = {
    autoStart = true;
    ephemeral = true;
    macvlans = [
      "enp0s25"
    ];
    bindMounts = {
      "/var" = {
        hostPath = "/data/mpanra-var";
        isReadOnly = false;
      };
      "/media" = {
        hostPath = "/data/media";
        isReadOnly = false;
      };
    };
    specialArgs.inputs = inputs;
    config = { inputs, ... }: {
      imports = [
        inputs.sops-nix.nixosModules.sops
        ../../../profiles/core.nix
        ./acme.nix
        ./bazarr.nix
        ./cloudflare-dyndns.nix
        ./home-assistant.nix
        ./jellyfin.nix
        ./kanidm.nix
        ./nextcloud.nix
        ./nginx.nix
        ./nix-serve.nix
        ./postgresql.nix
        ./radarr.nix
        ./sonarr.nix
        ./tiddlywiki.nix
      ];

      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.defaultSopsFile = ../../../secrets/mpanra/secrets.yaml;
      networking.useDHCP = false;
      networking.interfaces.mv-enp0s25.useDHCP = true;
      networking.tempAddresses = "disabled";

      system.stateVersion = "20.09";
    };
  };
}
