final: prev:
let
  pythonPackagesFor = pythonPackages: rec {
    datalad = pythonPackages.callPackage ./datalad.nix { inherit looseversion; };
    datalad-container = pythonPackages.callPackage ./datalad-container.nix { inherit datalad; };
    looseversion = pythonPackages.callPackage ./looseversion.nix { };
  };
in
{
  python39Packages = prev.python39Packages // (pythonPackagesFor prev.python39Packages);

  datalad = final.callPackage
    ({ lib, pythonPackages, extraPackages ? [ ] }: with pythonPackages; (toPythonApplication datalad).overrideAttrs (_: {
      preFixup = ''
        wrapProgram $out/bin/datalad --suffix PYTHONPATH : ${lib.makeSearchPath python.sitePackages (datalad.requiredPythonModules ++ extraPackages ++ (builtins.concatMap (p: p.requiredPythonModules) extraPackages))}:$out/${python.sitePackages}
      '';
    }))
    {
      pythonPackages = final.python39Packages;
      extraPackages = [
        final.python39Packages.datalad-container
      ];
    };

  smtp2paperless = prev.callPackage ./smtp2paperless.nix { };

  dply = prev.callPackage (import ./scripts.nix).dply { };
  nixos-config-path = prev.callPackage (import ./scripts.nix).nixos-config-path { };
  generate-hostnames = prev.callPackage (import ./scripts.nix).generate-hostnames { };
  lint.vulnix = prev.callPackage (import ./scripts.nix).lint.vulnix { };
  ci = prev.callPackage (import ./scripts.nix).ci { };
}
