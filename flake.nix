{
  description = "My NixOS configuration as a flake.";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      systems = [ "aarch64-darwin" "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux" ];
      forAllSystems = f: inputs.nixpkgs.lib.genAttrs systems (system: f system);
    in
    {

      devShell = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.self.overlay
              inputs.deploy-rs.overlay
              inputs.sops-nix.overlay
            ];
          };
        in
        pkgs.mkShell {
          name = "nixfiles";
          buildInputs = with pkgs; [ git nixUnstable sops age ssh-to-age nixpkgs-fmt deploy-rs.deploy-rs ];
        });

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs { inherit system; overlays = [ inputs.self.overlay ]; });

      nixosConfigurations =
        let
          baseModules = [
            inputs.nixpkgs.nixosModules.notDetected
            inputs.home-manager.nixosModules.home-manager
            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
            {
              home-manager.useGlobalPkgs = true;
            }
            {
              nix.registry.self.flake = inputs.self;
            }
            ./profiles/core
          ];
        in
        {
          andromeda = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                firefox.enableGnomeExtensions = true;
              };
              overlays = [ inputs.self.overlay ];
            };
            modules = baseModules ++ [
              ./profiles/hosts/andromeda.nix
            ];
          };
          ara = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = { allowUnfree = true; };
              overlays = [ inputs.self.overlay ];
            };
            modules = baseModules ++ [
              ./profiles/hosts/ara.nix
            ];
          };
        };

      overlay = import ./pkgs;

      deploy.nodes = {
        andromeda = {
          hostname = "andromeda";
          sshUser = "root";

          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
              inputs.self.nixosConfigurations.andromeda;
          };
        };

        ara = {
          hostname = "ara.matrss.de";
          sshUser = "root";

          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
              inputs.self.nixosConfigurations.ara;
          };
        };
      };

      checks =
        let
          checksFor = system:
            let
              pkgs = inputs.nixpkgs.legacyPackages.${system};
            in
            {
              "lint/editorconfig-checker" = pkgs.runCommandLocal "lint_editorconfig-checker" { } ''
                cd ${./.}
                ${pkgs.editorconfig-checker}/bin/editorconfig-checker && touch $out
              '';
              "lint/gitleaks" = pkgs.runCommandLocal "lint_gitleaks" { } ''
                cd ${./.}
                ${pkgs.gitleaks}/bin/gitleaks detect --verbose --no-git --redact && touch $out
              '';
              "lint/nixpkgs-fmt" = pkgs.runCommandLocal "lint_nixpkgs-fmt" { } ''
                ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.} > $out
              '';
            };
        in
        inputs.nixpkgs.lib.recursiveUpdate
          (forAllSystems checksFor)
          (builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib);
    };
}
