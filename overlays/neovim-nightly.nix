final: prev:

{
  neovim-nightly = prev.neovim-unwrapped.overrideAttrs (old: rec {
    pname = "neovim-nightly";
    version = "nightly";

    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.tree-sitter ];

    src = prev.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "${version}";
      sha256 = "sha256-/XMyFx9bKOgMiOhlwVHO4Wt//vwJeHxy8VJPEqHVYJY=";
    };
  });
}
