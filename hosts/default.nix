inputs@{ self, ... }:

let
  inherit (builtins) attrValues removeAttrs;

  config = hostName: basePkgset: hmFlake: system:
    let
      pkgs = inputs.nixpkgsFor basePkgset system;
      inherit (basePkgset) lib;
      utils = import ../lib/utils.nix { inherit lib; };
    in
    lib.nixosSystem {
      inherit system;

      modules =
        let
          hm-config = { config, ... }: {
            options.home-manager.users = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submoduleWith {
                modules = with self.hmModules; [ wob autorotate ];
                specialArgs = { super = config; };
              });
            };

            config.home-manager = { useGlobalPkgs = true; };
          };

          core = self.nixosModules.profiles.core;

          global = {
            networking.hostName = hostName;
            nixpkgs = { pkgs = pkgs; };
            # nix.registry.nixpkgs.flake = inputs.nixpkgs;
            nix.registry = lib.mapAttrs (id: flake: { flake = flake; }) {
              self = basePkgset;
              inherit (inputs) large small rel2009;
            };
          };

          local = import "${toString ./.}/${hostName}.nix";

          flakeModules =
            attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        flakeModules ++ [
          basePkgset.nixosModules.notDetected
          hmFlake.nixosModules.home-manager
          core
          global
          local
          hm-config
          # self.nixosModules.profiles.adblock-hosts
          ({ _module.args = { hosts = import ../secrets/hosts.nix; }; })
        ];
    };

  # hosts = utils.recImport {
  #   dir = ./.;
  #   _import = config;
  # };
  # in hosts
in
{
  andromeda =
    config "andromeda" inputs.large inputs.home-manager "x86_64-linux";
  draco =
    config "draco" inputs.rel2009 inputs.home-manager-rel2009 "x86_64-linux";
  ara = config "ara" inputs.large inputs.home-manager "x86_64-linux";
}
