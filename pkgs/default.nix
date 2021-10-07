final: prev: {
  # datalad = prev.python37Packages.callPackage ./datalad.nix { };
  # networkmanager-ssh = prev.callPackage ./networkmanager-ssh.nix { };

  gitsh = prev.callPackage ./gitsh.nix { };
  zk = prev.callPackage ./zk.nix { };

  html-clock-plasmoid = prev.plasma5Packages.callPackage ./html-clock-plasmoid.nix { };

  scripts = prev.symlinkJoin {
    name = "scripts";
    paths = builtins.attrValues (import ./scripts.nix { pkgs = prev; });
  };
}
