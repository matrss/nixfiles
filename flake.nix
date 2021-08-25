{
  description = "My NixOS configuration as a flake.";

  inputs = {

    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";

    # TODO: get rid of nixpkgs in favor of large
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    large.url = "github:NixOS/nixpkgs/nixos-unstable";
    small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    rel2009.url = "github:NixOS/nixpkgs/nixos-20.09";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "large";

    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "large";

    neovim.url = "github:neovim/neovim?dir=contrib";
    neovim.inputs.nixpkgs.follows = "large";
    neovim.inputs.flake-utils.follows = "flake-utils";

    neuron.url = "github:srid/neuron";
    neuron.inputs.flake-utils.follows = "flake-utils";

    f2b-bans.url = "gitlab:matrss/fail2ban-bans";
    f2b-bans.inputs.nixpkgs.follows = "large";
    f2b-bans.inputs.flake-utils.follows = "flake-utils";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "large";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "large";
    deploy-rs.inputs.utils.follows = "flake-utils";
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
            inputs.devshell.overlay
            inputs.deploy-rs.overlay
            inputs.sops-nix.overlay
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
            devShell = pkgs.devshell.mkShell {
              imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
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
