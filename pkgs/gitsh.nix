{ stdenv, fetchzip, autoconf, automake115x, ruby, readline }:

let
  version = "0.14";
in
stdenv.mkDerivation {
  pname = "gitsh";
  inherit version;

  src = fetchzip {
    url = "https://github.com/thoughtbot/gitsh/releases/download/v${version}/gitsh-${version}.tar.gz";
    sha256 = "sha256-D1ThJyW6Y4GSlbrPJdAXwShcPIeOSKIPexuDuciHW+Y=";
  };

  nativeBuildInputs = [ autoconf automake115x readline ];
  buildInputs = [ ruby ];
}
