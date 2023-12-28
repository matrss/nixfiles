{
  description = "My NixOS configuration as a flake.";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence/master";

    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

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
              inputs.sops-nix.overlays.default
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
              opentofu
              generate-hostnames
              dply
              nixos-config-path
              jq
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
            ./profiles/core.nix
            {
              home-manager.useGlobalPkgs = true;
            }
          ];
        in
        {
          "hazuno.m.0px.xyz" = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = { allowUnfree = true; };
              overlays = [ inputs.self.overlays.default ];
            };
            modules = baseModules ++ [
              ./hosts/hazuno
            ];
            specialArgs.inputs = inputs;
          };
          "ipsmin.m.0px.xyz" = inputs.nixpkgs.lib.nixosSystem rec {
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
            specialArgs.inputs = inputs;
          };
          "nelvte.m.0px.xyz" = inputs.nixpkgs.lib.nixosSystem rec {
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

          "lint/tofu-fmt" = pkgs.runCommandLocal "lint.tofu-fmt" { } ''
            ${pkgs.opentofu}/bin/tofu fmt -check -recursive -diff ${./.} && touch $out
          '';
        });

      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix { inherit (inputs.self) checks; };

      hydraJobs =
        let
          inherit (inputs.nixpkgs) lib;
        in
        lib.foldr lib.recursiveUpdate { }
          [
            # Add checks
            (lib.foldr lib.recursiveUpdate { } (lib.flatten (map builtins.attrValues (builtins.attrValues (builtins.mapAttrs (system: check: builtins.mapAttrs (checkName: check: { "checks-${checkName}-${system}" = check; }) check) inputs.self.checks)))))
            # Add nixosConfigurations
            (lib.mapAttrs' (hostname: nixosConfiguration: lib.nameValuePair "nixos-${hostname}" nixosConfiguration.config.system.build.toplevel) inputs.self.nixosConfigurations)
          ];
    };
}
