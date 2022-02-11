{ config, ... }:

{
  sops.secrets.nixfiles-deploy-token = {
    sopsFile = ../../secrets/secrets.yaml;
  };

  system.autoUpgrade = {
    enable = true;
    flake = "git+https://deploy@gitlab.com/matrss/nixfiles.git";
    dates = "07:00";
    allowReboot = false;
  };

  nix.envVars = { GIT_ASKPASS = "cat /run/secrets/nixfiles-deploy-token"; };
}
