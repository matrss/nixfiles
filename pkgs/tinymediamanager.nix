{ stdenv, fetchFromGitLab, maven }:

stdenv.mkDerivation rec {
  name = "tinymediamanager";
  version = "4.1.1";

  src = fetchFromGitLab {
    owner = "tinyMediaManager";
    repo = "tinyMediaManager";
    rev = "tinyMediaManager-${version}";
    sha256 = "sha256-mqheRAWdpj+UzK7OP8zODk2GbqDAJrOA/jH2tvVg/nY=";
  };

  nativeBuildInputs = [ maven ];

  buildPhase = "mvn package";
}
