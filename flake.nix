{
  description = "My NixOS configuration as a flake.";

  inputs = {

    # TODO: get rid of nixpkgs in favor of large
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    large.url = "github:NixOS/nixpkgs/nixos-unstable";
    small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    rel2009.url = "github:NixOS/nixpkgs/nixos-20.09";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "large";
    };

    emacs.url = "github:nix-community/emacs-overlay";

    neovim = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "large";
      inputs.flake-utils.follows = "flake-utils";
    };

    neuron.url = "github:srid/neuron";

    f2b-bans.url = "gitlab:matrss/fail2ban-bans";

    sops-nix.url = "github:Mic92/sops-nix";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "large";
    };

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ self, flake-utils, home-manager, ... }:
    let
      inherit (builtins) attrNames attrValues readDir pathExists;
      inherit (inputs.nixpkgs) lib;
      inherit (lib) removeSuffix recursiveUpdate genAttrs optionalAttrs;

      genAttrs' = values: f: builtins.listToAttrs (map f values);
      pathsToImportedAttrs = paths:
        genAttrs' paths (path: {
          name = removeSuffix ".nix" (baseNameOf path);
          value = import path;
        });

      diffTrace = left: right: string: value:
        if left != right then builtins.trace string value else value;

      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };

      # From bqv/nixrc
      # Nonstandard channel wrapper for build visibility
      channelToOverlay = { system, config, flake, branch }:
        (final: prev: {
          ${flake} = lib.mapAttrs
            (k: v:
              diffTrace (baseNameOf inputs.${flake}) (baseNameOf prev.path)
                "pkgs.${k} pinned to nixpkgs/${branch}"
                v)
            (import inputs.${flake} {
              inherit config system;
              overlays = [ ];
            });
        });
      # Nixpkgs enhanced with other releases
      nixpkgsFor = basePkgset: system:
        import basePkgset {
          inherit system config;
          overlays = (attrValues self.overlays) ++ [
            inputs.emacs.overlay
            inputs.neovim.overlay
            inputs.f2b-bans.overlay
            (channelToOverlay {
              inherit system config;
              flake = "nixpkgs";
              branch = "master";
            })
            (channelToOverlay {
              inherit system config;
              flake = "large";
              branch = "nixos-unstable";
            })
            (channelToOverlay {
              inherit system config;
              flake = "small";
              branch = "nixos-unstable-small";
            })
            (channelToOverlay {
              inherit system config;
              flake = "rel2009";
              branch = "nixos-20.09";
            })
            (final: prev: {
              neuron-notes = inputs.neuron.packages.${system}.neuron;
            })
          ];
        };
    in
    recursiveUpdate
      (flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "i686-linux" "aarch64-linux" ]
        (system:
          let pkgs = nixpkgsFor inputs.large system;
          in
          {
            devShell = pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                scripts

                git
                ssh-to-pgp
                nixFlakes

                inputs.deploy-rs.defaultPackage."${system}"
                inputs.sops-nix.packages."${system}".sops-import-keys-hook
              ];

              shellHook = self.checks.${system}.pre-commit-check.shellHook + ''
                export NIX_FLAKE_DIR="$PWD"
              '';
            };

            packages =
              let
                packages = self.overlay pkgs pkgs;
                overlays = lib.filterAttrs (n: v: n != "pkgs") self.overlays;
                overlayPkgs = genAttrs (attrNames overlays)
                  (name: (overlays."${name}" pkgs pkgs)."${name}");
              in
              recursiveUpdate packages overlayPkgs;

            apps =
              let
                scripts = import ./pkgs/scripts.nix { inherit pkgs; };
                f = name: flake-utils.lib.mkApp { drv = scripts."${name}"; };
              in
              genAttrs (attrNames scripts) f;

            checks = {
              pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
                src = ./.;
                hooks = {
                  nixpkgs-fmt.enable = true;
                  trailing-whitespace = {
                    enable = true;
                    name = "Trim Trailing Whitespace";
                    description = "This hook trims trailing whitespace.";
                    entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
                    types = [ "text" ];
                  };
                  end-of-file-fixer = {
                    enable = true;
                    name = "Fix End of Files";
                    description = "Ensures that a file is either empty, or ends with one newline.";
                    entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/end-of-file-fixer";
                    types = [ "text" ];
                  };
                  check-yaml = {
                    enable = true;
                    name = "Check Yaml";
                    description = "This hook checks yaml files for parseable syntax.";
                    entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/check-yaml";
                    types = [ "yaml" ];
                  };
                  check-added-large-files = {
                    enable = true;
                    name = "Check for added large files";
                    description = "Prevent giant files from being committed";
                    entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/check-added-large-files";
                  };
                  detect-private-key = {
                    enable = true;
                    name = "Detect Private Key";
                    description = "Detects the presence of private keys";
                    entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/detect-private-key";
                    types = [ "text" ];
                  };
                };
              };
            };
          }))
      {

        nixosConfigurations =
          import ./hosts (recursiveUpdate inputs {
            inherit nixpkgsFor;
          });

        nixosModules =
          let
            # modules
            moduleList = import ./modules/list.nix;
            modulesAttrs = pathsToImportedAttrs moduleList;

            # profiles
            profilesList = import ./profiles/list.nix;
            profilesAttrs = { profiles = pathsToImportedAttrs profilesList; };

          in
          recursiveUpdate modulesAttrs profilesAttrs;

        hmModules =
          let
            # modules
            moduleList = import ./modules/home-manager/list.nix;
            modulesAttrs = pathsToImportedAttrs moduleList;

            # TODO: add home-manager profiles (move them into profiles as well?)
          in
          modulesAttrs;

        overlay = import ./pkgs;

        overlays =
          let
            overlayDir = ./overlays;
            fullPath = name: overlayDir + "/${name}";
            overlayPaths = (map fullPath (attrNames (optionalAttrs (pathExists overlayDir) (readDir overlayDir))))
              ++ [ ./pkgs ];
          in
          pathsToImportedAttrs overlayPaths;

        deploy.nodes = {
          andromeda = {
            hostname = "andromeda";
            sshUser = "root";

            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations.andromeda;
            };
          };

          ara = {
            hostname = "ara.matrss.de";
            sshUser = "root";

            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations.ara;
            };
          };
        };

        # This is highly advised, and will prevent many possible mistakes
        checks = builtins.mapAttrs
          (system: deployLib: deployLib.deployChecks self.deploy)
          inputs.deploy-rs.lib;
      };
}
