{ buildGoModule, fetchFromGitHub, icu }:

let
  version = "0.5.0";
in
buildGoModule {
  pname = "zk";
  inherit version;

  src = fetchFromGitHub {
    owner = "mickael-menu";
    repo = "zk";
    rev = "v${version}";
    hash = "sha256-EFVNEkBYkhArtUfULZVRPxFCVaPHamadqFxi7zV7y8g=";
  };

  buildInputs = [ icu ];

  buildFlagsArray = [ "-tags=icu fts5" ];

  runVend = true;

  vendorSha256 = "sha256-pkW51qXK03h7eIk8MWIHBknmGrd+bUq8V3ZzkNnpP8c=";

  doCheck = false;
}
