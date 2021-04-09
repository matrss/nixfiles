{ stdenv, fetchurl, meson, ninja, cmake, pkg-config, glib, gsound, libgudev
, json-glib, gobject-introspection, vala, libxkbcommon }:

stdenv.mkDerivation rec {
  pname = "feedbackd";
  version = "0.0.0+git20200726";
  # version = "master";

  src = fetchurl {
    url =
      "https://source.puri.sm/Librem5/feedbackd/-/archive/v${version}/feedbackd-v${version}.tar.gz";
    sha256 = "sha256-6WMtHR7yKLt/bKPT2HWAaypXY7Te9OMOlKzwx/Pree8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    glib
    gsound
    libgudev
    json-glib
    gobject-introspection
    vala
    libxkbcommon
  ];

  buildInputs = [ cmake libxkbcommon ];

  meta = with lib; {
    homepage = "https://source.puri.sm/Librem5/feedbackd";
    description =
      "A daemon to provide haptic (and later more) feedback on events";
    # license = licenses.mit;
    # maintainers = [ ];
  };
}
