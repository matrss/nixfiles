{ stdenv
, fetchurl
, meson
, ninja
, pkg-config
, wayland
, git
, wlroots
, gcc10
, libffi
, cereal
, tl-expected
}:

stdenv.mkDerivation rec {
  pname = "cardboard";
  version = "master";

  src = fetchurl {
    url =
      "https://gitlab.com/cardboardwm/cardboard/-/archive/${version}/cardboard-${version}.tar.gz";
    sha256 = "sha256-aP32liMyNvT3L9OvPYmc7UdhWEfmCnWOSqE+pVjIeq8=";
  };

  nativeBuildInputs =
    [ meson ninja pkg-config gcc10 git cereal wlroots tl-expected ]
    ++ wlroots.nativeBuildInputs;

  buildInputs = [ wayland libffi ] ++ wlroots.buildInputs;

  meta = with lib; {
    homepage = "https://gitlab.com/cardboardwm/cardboard";
    description = ''
      Cardboard is a unique, scrollable tiling Wayland compositor designed with
      laptops in mind. Based on wlroots.'';
    # license = licenses.mit;
    # maintainers = [ ];
  };
}
