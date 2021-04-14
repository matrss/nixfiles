{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.password-store;

in
{

  options.programs.password-store = {
    # enableBashIntegration = mkOption {
    #   default = true;
    #   type = types.bool;
    #   description = ''
    #     Whether to enable Bash integration.
    #   '';
    # };

    enableZshIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Zsh integration.
      '';
    };

    # enableFishIntegration = mkOption {
    #   default = true;
    #   type = types.bool;
    #   description = ''
    #     Whether to enable Fish integration.
    #   '';
    # };
  };

  config = mkIf cfg.enable {
    # programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
    #   eval "$(${pkgs.pazi}/bin/pazi init bash)"
    # '';

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
      if [[ $options[zle] = on ]]; then
        source ${pkgs.pass}/share/zsh/site-functions/_pass
      fi
    '';

    # programs.fish.shellInit = mkIf cfg.enableFishIntegration ''
    #   ${pkgs.pass}/share/fish/vendor_completions.d/pass.fish
    # '';
  };

}
