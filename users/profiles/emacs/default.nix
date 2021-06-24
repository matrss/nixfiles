{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithPackagesFromUsePackage {
      config = ./emacs.d/init.el;
      alwaysEnsure = true;
    };
    # extraPackages = with pkgs; (epkgs:
    #   with epkgs; [
    #     fd
    #     ripgrep

    #     use-package
    #     use-package-hydra
    #     which-key
    #     evil
    #     evil-leader
    #     ivy
    #     counsel
    #     swiper
    #     hydra
    #     ivy-hydra
    #     direnv
    #     projectile
    #     magit
    #     undo-fu
    #     ein
    #     key-chord

    #     telephone-line
    #     base16-theme

    #     polymode
    #     nix-mode
    #     markdown-mode
    #     poly-markdown
    #     dockerfile-mode
    #     docker-compose-mode
    #   ]);
  };

  # services.emacs = {
  #   enable = true;
  #   client.enable = true;
  # };

  home.file.".emacs.d/early-init.el".source = ./emacs.d/early-init.el;
  home.file.".emacs.d/init.el".source = ./emacs.d/init.el;
}
