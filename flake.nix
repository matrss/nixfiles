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
      systems = [ "x86_64-linux" ];
      forAllSystems = f: inputs.nixpkgs.lib.genAttrs systems (system: f system);
    in
    {

      devShells = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.self.overlays.default
              inputs.deploy-rs.overlay
              inputs.sops-nix.overlay
            ];
          };
        in
        {
          default = pkgs.mkShell {
            name = "nixfiles";
            buildInputs = with pkgs; [ git nixUnstable sops age ssh-to-age nixpkgs-fmt deploy-rs.deploy-rs ];
          };
        });

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs { inherit system; overlays = [ inputs.self.overlays.default ]; });

      nixosConfigurations =
        let
          baseModules = [
            inputs.home-manager.nixosModules.home-manager
            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
            {
              home-manager.useGlobalPkgs = true;
            }
            {
              nix.registry.self.flake = inputs.self;
            }
            ./profiles/core.nix
          ];
        in
        {
          ipsmin = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                firefox.enableGnomeExtensions = true;
              };
              overlays = [ inputs.self.overlays.default ];
            };
            modules = baseModules ++ [
              ./hosts/ipsmin
            ];
          };
          nelvte = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = { allowUnfree = true; };
              overlays = [ inputs.self.overlays.default ];
            };
            modules = baseModules ++ [
              ./hosts/nelvte
            ];
          };
        };

      overlays.default = import ./pkgs;

      deploy.nodes = {
        ipsmin = {
          hostname = "ipsmin";
          sshUser = "root";

          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
              inputs.self.nixosConfigurations.ipsmin;
          };
        };

        nelvte = {
          hostname = "nelvte.matrss.de";
          sshUser = "root";

          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
              inputs.self.nixosConfigurations.nelvte;
          };
        };
      };

      hydraJobs = {
        test-job.x86_64-linux = (inputs.nixpkgs.legacyPackages.x86_64-linux).runCommandLocal "test-job" { } ''
          echo "Test Job!" | tee $out
        '';
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
                ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.} | tee $out
              '';
            } // (builtins.mapAttrs (_: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib).${system};
        in
        forAllSystems checksFor;
    };
}
