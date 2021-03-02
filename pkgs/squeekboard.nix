{ stdenv, fetchurl, meson, ninja, cmake, rustc, cargo, pkg-config, glib, wayland
, wayland-protocols, gnome3, gtk3, libxkbcommon, feedbackd }:

stdenv.mkDerivation rec {
  pname = "squeekboard";
  version = "1.10.0";

  src = fetchurl {
    url =
      "https://source.puri.sm/Librem5/squeekboard/-/archive/v${version}/squeekboard-v${version}.tar.gz";
    sha256 = "sha256-+F0EnInrV4Hp0lG6vpDDhlay5kN+x96LPJo9EANVzk8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    rustc
    cargo
    pkg-config
    glib
    wayland
    gnome3.gnome-desktop
    gtk3
  ];

  buildInputs = [ wayland wayland-protocols feedbackd libxkbcommon ];

  meta = with stdenv.lib; {
    homepage = "https://source.puri.sm/Librem5/squeekboard";
    description = "The final Librem5 keyboard";
    # license = licenses.mit;
    # maintainers = [ ];
  };
}
