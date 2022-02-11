{
  description = "My NixOS configuration as a flake.";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
    let
      systems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f: inputs.nixpkgs.lib.genAttrs systems (system: f system);
    in
    {

      devShell = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system; overlays = [
            self.overlay
            inputs.deploy-rs.overlay
            inputs.sops-nix.overlay
          ];
          };
        in
        pkgs.mkShell {
          name = "nixfiles";
          buildInputs = with pkgs; [ git nixUnstable sops sops-import-keys-hook nixpkgs-fmt deploy-rs.deploy-rs ];
        });

      nixosConfigurations =
        let
          baseModules = [
            inputs.nixpkgs.nixosModules.notDetected
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            {
              home-manager.useGlobalPkgs = true;
            }
            ./profiles/core
          ];
        in
        {
          andromeda = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; overlays = [ self.overlay ]; };
            modules = baseModules ++ [
              ./profiles/hosts/andromeda.nix
            ];
          };
          ara = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            pkgs = import inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; overlays = [ self.overlay ]; };
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

      ciJobs = {
        build.andromeda = self.nixosConfigurations.andromeda.config.system.build.toplevel;
        build.ara = self.nixosConfigurations.ara.config.system.build.toplevel;
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    };
}
