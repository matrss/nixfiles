final: prev:
let
  dataladFor = pythonPackages: rec {
    datalad = pythonPackages.callPackage ./datalad.nix { };
    datalad-container = pythonPackages.callPackage ./datalad-container.nix { inherit datalad; };
  };
in
{
  python39Packages = prev.python39Packages // (dataladFor final.python39Packages);

  datalad = final.callPackage
    ({ lib, pythonPackages, extraPackages ? [ ] }: with pythonPackages; (toPythonApplication datalad).overrideAttrs (old: {
      preFixup = ''
        wrapProgram $out/bin/datalad --suffix PYTHONPATH : ${lib.makeSearchPath python.sitePackages (datalad.requiredPythonModules ++ extraPackages ++ (builtins.concatMap (p: p.requiredPythonModules) extraPackages))}:$out/${python.sitePackages}
      '';
    }))
    { pythonPackages = final.python39Packages; extraPackages = [ final.python39Packages.datalad-container ]; };

  generate-hostnames = prev.callPackage (import ./scripts.nix).generate-hostnames { };
}
