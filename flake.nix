{
  description = "My NixOS configuration as a flake.";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    large.url = "github:NixOS/nixpkgs/nixos-unstable";
    small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    rel2009-tempsecretsfix.url = "/home/matrss/Projects/nixpkgs";
    rel2009.url = "github:NixOS/nixpkgs/nixos-20.09";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:matrss/home-manager/mako_as_a_service";
      # url = "/home/matrss/Projects/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-rel2009 = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "rel2009";
    };

    emacs.url = "github:nix-community/emacs-overlay";

    nur.url = "github:nix-community/nur";

    deploy-rs.url = "github:serokell/deploy-rs";

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ self, flake-utils, home-manager, ... }:
    let
      inherit (builtins) attrNames attrValues readDir;
      inherit (inputs.nixpkgs) lib;
      inherit (lib) removeSuffix recursiveUpdate genAttrs;

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
          ${flake} = lib.mapAttrs (k: v:
            diffTrace (baseNameOf inputs.${flake}) (baseNameOf prev.path)
            "pkgs.${k} pinned to nixpkgs/${branch}" v) (import inputs.${flake} {
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
            inputs.nur.overlay
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
          ];
        };
    in flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgsFor inputs.nixpkgs system;
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            git
            git-crypt
            nixFlakes
            nixfmt
            inputs.deploy-rs.defaultPackage."${system}"
          ];
          shellHook = ''
            export PATH="$PWD/utils:$PATH"
          '';
          # shellHook = ''
          #   # mkdir -p secrets
          #   PATH=${
          #     pkgs.writeShellScriptBin "nix" ''
          #       ${pkgs.nixFlakes}/bin/nix --option experimental-features "nix-command flakes ca-references" "$@"
          #     ''
          #   }/bin:$PATH
          # '';
        };

        packages = let
          packages = self.overlay pkgs pkgs;
          overlays = lib.filterAttrs (n: v: n != "pkgs") self.overlays;
          overlayPkgs = genAttrs (attrNames overlays)
            (name: (overlays."${name}" pkgs pkgs)."${name}");
        in recursiveUpdate packages overlayPkgs;

      }) // {

        nixosConfigurations =
          import ./hosts (recursiveUpdate inputs { inherit nixpkgsFor; });

        nixosModules = let
          # modules
          moduleList = import ./modules/list.nix;
          modulesAttrs = pathsToImportedAttrs moduleList;

          # profiles
          profilesList = import ./profiles/list.nix;
          profilesAttrs = { profiles = pathsToImportedAttrs profilesList; };

        in recursiveUpdate modulesAttrs profilesAttrs;

        hmModules = let
          # modules
          moduleList = import ./modules/home-manager/list.nix;
          modulesAttrs = pathsToImportedAttrs moduleList;
        in modulesAttrs;

        overlay = import ./pkgs;

        overlays = let
          overlayDir = ./overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = (map fullPath (attrNames (readDir overlayDir)))
            ++ [ ./pkgs ];
        in pathsToImportedAttrs overlayPaths;

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

          draco = {
            hostname = "168.119.121.219";
            sshUser = "root";

            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations.draco;
            };
          };

          ara = {
            # hostname = "ara";
            hostname = "10.0.0.2";
            sshUser = "root";

            # autoRollback = false;

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
