{ pkgs, ... }:

{
  programs.skim.enable = true;
  programs.pazi.enable = true;
  programs.dircolors.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = " [>](bold green)";
        error_symbol = " [>](bold red)";
        vicmd_symbol = " :";
      };
    };
  };

  programs.zsh = {
    enable = true;

    enableCompletion = true;

    defaultKeymap = "viins";

    shellAliases = {
      t = "todo.sh -a -t -d $XDG_CONFIG_HOME/todotxt/todo.cfg";
      ls = "ls --color";
    };

    initExtra = ''
      # case-insensitive (uppercase from lowercase) completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      e() {
        nohup neovide --geometry=195x45 $@ > /dev/null 2>&1 & disown
      }

      # if [[ $DISPLAY ]]; then
      #   [[ $- != *i* ]] && return
      #   if [[ -z "$TMUX" ]]; then
      #     ID="$(${pkgs.tmux}/bin/tmux ls | grep -vm1 attached | cut -d: -f1)"
      #     if [[ -z "$ID" ]]; then
      #       ${pkgs.tmux}/bin/tmux new-session
      #     else
      #       ${pkgs.tmux}/bin/tmux attach-session -t "$ID"
      #     fi
      #   fi
      # fi
    '';
  };
}
