{ config, ... }:

{
  sops.secrets."nix-serve/secret-key" = { };

  services.nix-serve = {
    enable = true;
    bindAddress = "127.0.0.1";
    secretKeyFile = config.sops.secrets."nix-serve/secret-key".path;
  };

  services.nginx.virtualHosts."nix-cache.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "mpanra.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}";
      proxyWebsockets = true;
    };
  };
}
