{ inputs, pkgs, ... }:

{
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    neovim
  ];

  nix = {
    # Enable flakes support.
    extraOptions =
      let
        flake-registry = builtins.toJSON
          {
            flakes = [{
              from = { type = "indirect"; id = "templates"; };
              to = { type = "github"; owner = "NixOS"; repo = "templates"; };
            }];
            version = 2;
          };
      in
      ''
        experimental-features = nix-command flakes
        flake-registry = ${pkgs.writeText "flake-registry.json" flake-registry}
      '';
    gc.automatic = true;
    optimise.automatic = true;
    registry.self.flake = inputs.self;
    settings.allowed-users = [ "@users" ];
    settings.trusted-users = [ "@wheel" ];
  };

  home-manager.useGlobalPkgs = true;

  boot.tmp.useTmpfs = true;

  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;
  security.sudo.execWheelOnly = true;
}
