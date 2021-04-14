{ stdenv
, fetchurl
, meson
, ninja
, pkg-config
, wayland
, wayland-protocols
, libxkbcommon
, cairo
, wrapGAppsHook
, gsettings-desktop-schemas
}:

stdenv.mkDerivation rec {
  pname = "virtboard";
  version = "0.0.6";
  # version = "master";

  src = fetchurl {
    url =
      "https://source.puri.sm/Librem5/virtboard/-/archive/v${version}/virtboard-v${version}.tar.gz";
    # url = "https://source.puri.sm/Librem5/virtboard/-/archive/${version}/virtboard-${version}.tar.gz";
    sha256 = "sha256-CETQCwzaYIDWosW44Efd8IfF9fJnpijRVAM8eES0EYE=";
    # sha256 = "sha256-fA2zIt8LO6JfIzqIlV8p2Wa7sWCdqzpxuUovOYp+oWQ=";
  };

  nativeBuildInputs = [ meson ninja pkg-config wayland wrapGAppsHook ];

  buildInputs =
    [ wayland wayland-protocols libxkbcommon cairo gsettings-desktop-schemas ];

  postInstall = ''
    wrapGApp "$out/bin/virtboard"
  '';

  meta = with lib; {
    homepage = "https://source.puri.sm/Librem5/virtboard";
    description =
      "A basic keyboard, blazing the path of modern Wayland keyboards. Sacrificial.";
    # license = licenses.mit;
    # maintainers = [ ];
  };
}
