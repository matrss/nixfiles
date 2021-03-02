{ stdenv, fetchFromGitHub, cmake, plasma5, qt5, kdeFrameworks }:

stdenv.mkDerivation rec {
  pname = "lightly";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "Luwx";
    repo = "Lightly";
    rev = "v${version}";
    sha256 = "sha256-ulHxDYjQ//uUVnf1VWpvNEByWCJ1nNh3TBw2HIR5e2I=";
  };

  nativeBuildInputs = [
    cmake
    kdeFrameworks.kwindowsystem
    kdeFrameworks.kiconthemes
    kdeFrameworks.kconfigwidgets
    kdeFrameworks.kguiaddons
    kdeFrameworks.extra-cmake-modules
    kdeFrameworks.kcoreaddons
    plasma5.kdecoration
    qt5.qtdeclarative
    qt5.qtx11extras
  ];
}
