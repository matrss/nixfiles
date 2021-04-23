final: prev: {
  # datalad = prev.python37Packages.callPackage ./datalad.nix { };
  # networkmanager-ssh = prev.callPackage ./networkmanager-ssh.nix { };

  scripts = prev.symlinkJoin {
    name = "scripts";
    paths = builtins.attrValues (import ./scripts.nix { pkgs = prev; });
  };
}
