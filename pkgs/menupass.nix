{ stdenv, fetchFromGitHub, makeWrapper, bemenu, wtype, pass }:

stdenv.mkDerivation rec {
  name = "menupass";
  version = "master";

  src = fetchFromGitHub {
    owner = "matrss";
    repo = "menupass";
    rev = version;
    sha256 = "sha256-Mm4hPIqBkSGKzXLWOpY6Cq1A9EnYkmL7uhkC08l1rRg=";
  };

  buildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -a menupass $out/bin/menupass
  '';

  wrapperPath = lib.makeBinPath [ bemenu wtype pass ];

  fixupPhase = ''
    wrapProgram $out/bin/menupass \
      --prefix PATH : "${wrapperPath}"
  '';
}
