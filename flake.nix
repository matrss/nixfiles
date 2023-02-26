{
  description = "My NixOS configuration as a flake.";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
    in
    {

      devShells = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.self.overlays.default
              inputs.sops-nix.overlay
            ];
          };
        in
        {
          default = pkgs.mkShell {
            name = "nixfiles";
            buildInputs = with pkgs; [
              git
              nixUnstable
              sops
              age
              ssh-to-age
              nixpkgs-fmt
              terraform
              generate-hostnames
              dply
            ];
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
          hazuno = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = { allowUnfree = true; };
              overlays = [ inputs.self.overlays.default ];
            };
            modules = baseModules ++ [
              ./hosts/hazuno
            ];
          };
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
            specialArgs.inputs = inputs;
          };
        };

      overlays.default = import ./pkgs;

      checks = forAllSystems (system:
        let
          nixpkgsFor = system: inputs.nixpkgs.legacyPackages.${system};
          pkgs = nixpkgsFor system;
        in
        {
          "lint/deadnix" = pkgs.runCommandLocal "lint.deadnix" { } ''
            ${pkgs.deadnix}/bin/deadnix --fail --hidden ${./.} && touch $out
          '';

          "lint/editorconfig-checker" = pkgs.runCommandLocal "lint.editorconfig-checker" { } ''
            cd ${./.}
            ${pkgs.editorconfig-checker}/bin/editorconfig-checker && touch $out
          '';

          "lint/gitleaks" = pkgs.runCommandLocal "lint.gitleaks" { } ''
            cd ${./.}
            ${pkgs.gitleaks}/bin/gitleaks detect --verbose --no-git --redact && touch $out
          '';

          "lint/nixpkgs-fmt" = pkgs.runCommandLocal "lint.nixpkgs-fmt" { } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.} | tee $out
          '';

          "lint/statix" = pkgs.runCommandLocal "lint.statix" { } ''
            ${pkgs.statix}/bin/statix check ${./.} && touch $out
          '';
        });
    };
}
