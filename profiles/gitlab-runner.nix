{ lib, pkgs, config, ... }:

{
  sops.secrets.gitlab-runner-env = { };

  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  virtualisation.docker.enable = true;
  services.gitlab-runner = {
    enable = true;
    services =
      let
        dockerRunner = with lib; {
          # File should contain at least these two variables:
          # `CI_SERVER_URL`
          # `REGISTRATION_TOKEN`
          registrationConfigFile = config.sops.secrets.gitlab-runner-env.path;
          dockerImage = "debian:stable";
        }; in
      {
        # runners for building in docker via host's nix-daemon
        # nix store will be readable in runner, might be insecure
        docker = lib.recursiveUpdate dockerRunner { protected = false; registrationFlags = [ "--name=ara-docker" ]; };
        dockerProtected = lib.recursiveUpdate dockerRunner { protected = true; registrationFlags = [ "--name=ara-docker-protected" ]; };
      };
  };
}
