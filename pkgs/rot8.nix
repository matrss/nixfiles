{ lib, stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "rot8";
  version = "master";

  src = fetchFromGitHub {
    owner = "efernau";
    repo = "rot8";
    rev = "${version}";
    sha256 = "sha256-tXKf/aGD+BJDJeDmfqZBPcG75rmD+iVvj9QB5g+8Bl0=";
  };

  cargoSha256 = "sha256-7tNG16OKijGfrMmxvSR5L+D1biV2qMNNXQtPD/Hn308=";

  meta = with lib; {
    homepage = "https://github.com/efernau/rot8";
    description =
      "Automatic display rotation using built-in accelerometer for sway and X11.";
    license = licenses.mit;
    maintainers = [ ];
  };
}
