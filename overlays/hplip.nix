final: prev: {
  hplip = prev.hplip.overrideAttrs
    (old: { pythonPath = old.pythonPath ++ [ prev.python3Packages.distro ]; });
}
