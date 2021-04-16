final: prev: {
  rot8 = prev.callPackage ./rot8.nix { };
  autorotate = prev.callPackage ./autorotate { };
  # jupytext = prev.callPackage ./jupytext.nix { inherit (prev.python3.pkgs) buildPythonPackage fetchPypi isPy27 mock nbformat; };
  # jupytext = prev.python3.pkgs.callPackage ./jupytext.nix { };
  # conda = prev.callPackage ./conda.nix { };
  # xplot = prev.callPackage ./xplot.nix { };
  # tcptrace = prev.callPackage ./tcptrace.nix { };
  virtboard = prev.callPackage ./virtboard.nix { };
  # feedbackd = prev.callPackage ./feedbackd.nix { };
  # squeekboard = prev.callPackage ./squeekboard.nix { };
  # cardboard = prev.callPackage ./cardboard.nix { };
  pier = prev.callPackage ./pier.nix { };
  menupass = prev.callPackage ./menupass.nix { };
  datalad = prev.python37Packages.callPackage ./datalad.nix { };
  # lightly = prev.callPackage ./lightly.nix { };
  networkmanager-ssh = prev.callPackage ./networkmanager-ssh.nix { };
  tinymediamanager = prev.callPackage ./tinymediamanager.nix { };

  scripts = prev.symlinkJoin {
    name = "scripts";
    paths = builtins.attrValues (import ./scripts.nix { pkgs = prev; });
  };
}
