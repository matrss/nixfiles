_final: prev:

{
  generate-hostnames = prev.callPackage (import ./scripts.nix).generate-hostnames { };
  smtp2paperless = prev.callPackage ./smtp2paperless.nix { };
}
