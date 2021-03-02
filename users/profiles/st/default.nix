{ pkgs, ... }:

{
  # nixpkgs.config.st = {
  #   conf = builtins.readFile ./st-config.h;
  #   patches = builtins.map builtins.fetchurl [
  #     { url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.2.diff";
  #       sha256 = "0rnigxkldl22dwl6b1743dza949w9j4p1akqvdxl74gi5z7fsnlw";
  #     }
  #     { url = "https://st.suckless.org/patches/xresources/st-xresources-20190105-3be4cf1.diff";
  #       sha256 = "112zi7jqzj6601gp54nr4b7si99g29lz61c44rgcpgpfddwmpibi";
  #     }
  #   ];
  # };
  # nixpkgs.config.packageOverrides = pkgs:
  #   { st = pkgs.st.override {
  #       conf = builtins.readFile ./st-config.h;
  #       patches = builtins.map builtins.fetchurl [
  #         { url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.2.diff";
  #           sha256 = "0rnigxkldl22dwl6b1743dza949w9j4p1akqvdxl74gi5z7fsnlw";
  #         }
  #         { url = "https://st.suckless.org/patches/xresources/st-xresources-20190105-3be4cf1.diff";
  #           sha256 = "112zi7jqzj6601gp54nr4b7si99g29lz61c44rgcpgpfddwmpibi";
  #         }
  #       ];
  #     };
  #   };

  home.packages = with pkgs; [ noto-fonts st ];
}
