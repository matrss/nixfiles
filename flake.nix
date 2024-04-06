{
  description = "My NixOS configuration as a flake.";

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

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
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
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
              jq
            ];
          };
        });

      nixosConfigurations =
        let
          baseModules = [
            inputs.home-manager.nixosModules.home-manager
            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
            ./profiles/core.nix
            ./profiles/upgrade.nix
            {
              home-manager.useGlobalPkgs = true;
            }
          ];
        in
        {
          hazuno_m_0px_xyz = inputs.nixpkgs.lib.nixosSystem rec {
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
          ipsmin_m_0px_xyz = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = { allowUnfree = true; };
              overlays = [ inputs.self.overlays.default ];
            };
            modules = baseModules ++ [
              ./hosts/ipsmin
            ];
            specialArgs.inputs = inputs;
          };
          nelvte_m_0px_xyz = inputs.nixpkgs.lib.nixosSystem rec {
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
          "lint/deadnix" = pkgs.runCommand "lint.deadnix" { } ''
            cd ${./.}
            ${pkgs.deadnix}/bin/deadnix --fail --hidden && touch $out
          '';

          "lint/editorconfig-checker" = pkgs.runCommand "lint.editorconfig-checker" { } ''
            cd ${./.}
            ${pkgs.editorconfig-checker}/bin/editorconfig-checker && touch $out
          '';

          "lint/gitleaks" = pkgs.runCommand "lint.gitleaks" { } ''
            cd ${./.}
            ${pkgs.gitleaks}/bin/gitleaks detect --verbose --no-git --redact && touch $out
          '';

          "lint/nixpkgs-fmt" = pkgs.runCommand "lint.nixpkgs-fmt" { } ''
            cd ${./.}
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check . | tee $out
          '';

          "lint/statix" = pkgs.runCommand "lint.statix" { } ''
            cd ${./.}
            ${pkgs.statix}/bin/statix check && touch $out
          '';

          "lint/tofu-fmt" = pkgs.runCommand "lint.tofu-fmt" { } ''
            cd ${./.}
            ${pkgs.opentofu}/bin/tofu fmt -check -recursive -diff && touch $out
          '';

          "impure-test" = pkgs.stdenv.mkDerivation {
            name = "impure-test";
            __noChroot = true;
            nativeBuildInputs = [ pkgs.cacert pkgs.git pkgs.nix ];
            buildCommand = ''
              export HOME=$(mktemp -d)
              git clone https://github.com/matrss/nixfiles latest
              git clone https://github.com/matrss/nixfiles older
              git -C older switch --detach HEAD~5
              nix --extra-experimental-features "nix-command flakes" --accept-flake-config store diff-closures --derivation ./older#nixosConfigurations.hazuno_m_0px_xyz.config.system.build.toplevel ./latest#nixosConfigurations.hazuno_m_0px_xyz.config.system.build.toplevel
              touch $out
            '';
          };
        });
    };
}
