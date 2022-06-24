{ config, ... }:

{
  sops.secrets."hydra/secret-key" = { };

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.matrss.xyz";
    notificationSender = "";
    useSubstitutes = true;
    listenHost = "localhost";
    extraConfig = ''
      binary_cache_secret_key_file = ${config.sops.secrets."hydra/secret-key".path}
    '';
  };

  services.nginx.virtualHosts."hydra.matrss.xyz" = {
    forceSSL = true;
    useACMEHost = "nelvte.matrss.xyz";
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

  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 8;
    }
  ];
}
