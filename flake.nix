{
  description = "My NixOS configuration as a flake.";

  inputs = {

    devshell.url = "github:numtide/devshell";

    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.0";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, flake-utils, ... }: flake-utils.lib.mkFlake {
    inherit self inputs;

    channelsConfig.allowUnfree = true;

    sharedOverlays = [
      self.overlay
      inputs.devshell.overlay
      inputs.deploy-rs.overlay
      inputs.sops-nix.overlay
    ];

    hostDefaults.modules = [
      inputs.nixpkgs.nixosModules.notDetected
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      {
        home-manager.useGlobalPkgs = true;
      }
      ./profiles/core
    ];

    hosts.andromeda.modules = [
      ./hosts/andromeda.nix
    ];

    hosts.ara.modules = [
      ./hosts/ara.nix
    ];

    outputsBuilder = channels: {
      packages = flake-utils.lib.exportPackages self.overlays channels;

      devShell = channels.nixpkgs.devshell.mkShell {
        imports = [ (channels.nixpkgs.devshell.importTOML ./devshell.toml) ];
      };
    };

    overlays = flake-utils.lib.exportOverlays {
      inherit (self) pkgs inputs;
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
  };
}
