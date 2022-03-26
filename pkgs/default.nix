final: prev: {
  scripts = prev.symlinkJoin {
    name = "scripts";
    paths = builtins.attrValues (import ./scripts.nix { pkgs = prev; });
  };
}
