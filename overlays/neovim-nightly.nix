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
      sha256 = "sha256-It3T+GGOtw8pEZk/T1n/W7lgJ8f22w/2h8Lni7RMtYo=";
    };
  });
}
