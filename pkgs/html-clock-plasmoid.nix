{ lib
, mkDerivation
, fetchFromGitHub
, plasma-framework
}:

mkDerivation rec {
  pname = "html-clock-plasmoid";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "MarcinOrlowski";
    repo = "html-clock-plasmoid";
    rev = "${version}";
    hash = "sha256-ZSFK31q+bIetuLM0c+82JnqXO5/iQIJyPxIvofeXDVo=";
  };

  buildInputs = [ plasma-framework ];

  buildPhase = ''
  runHook preBuild
  sh -c 'export ROOT_DIR=$(pwd); source bin/common.sh; dumpMeta > src/contents/js/meta.js'
  runHook postBuild
  '';

  installPhase = ''
  runHook preInstall
  mkdir -p $out/share/plasma/plasmoids/com.marcinorlowski.htmlclock
  cp -r src/* $out/share/plasma/plasmoids/com.marcinorlowski.htmlclock
  runHook postInstall
  '';

  meta = with lib; {
    description = "Plasma/KDE clock widget you can layout and style using HTML/CSS!";
    homepage = "https://github.com/MarcinOrlowski/html-clock-plasmoid";
  };
}
