_final: prev:

{
  dply = prev.callPackage (import ./scripts.nix).dply { };
  generate-hostnames = prev.callPackage (import ./scripts.nix).generate-hostnames { };
  nixos-config-path = prev.callPackage (import ./scripts.nix).nixos-config-path { };
  smtp2paperless = prev.callPackage ./smtp2paperless.nix { };
}
