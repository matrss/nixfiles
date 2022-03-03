final: prev: {
  python38Packages = prev.python38Packages // rec {
    datalad = final.python38Packages.callPackage ./datalad.nix { };
    datalad-container = final.python38Packages.callPackage ./datalad-container.nix { inherit datalad; };
  };

  datalad = final.callPackage
    ({ lib, python38Packages, extraPackages ? [ ] }: with python38Packages; (toPythonApplication datalad).overrideAttrs (old: {
      preFixup = ''
        wrapProgram $out/bin/datalad --suffix PYTHONPATH : ${lib.makeSearchPath python.sitePackages (datalad.requiredPythonModules ++ extraPackages ++ (builtins.concatMap (p: p.requiredPythonModules) extraPackages))}:$out/${python.sitePackages}
      '';
    }))
    { extraPackages = [ final.python38Packages.datalad-container ]; };

  scripts = prev.symlinkJoin {
    name = "scripts";
    paths = builtins.attrValues (import ./scripts.nix { pkgs = prev; });
  };
}
