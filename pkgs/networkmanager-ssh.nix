{ lib, stdenv, fetchFromGitHub, substituteAll, vpnc, intltool, pkg-config
, networkmanager, libsecret, gtk3, withGnome ? true, gnome3, glib, kmod, file
, fetchpatch, libnma }:
let
  pname = "NetworkManager-ssh";
  version = "1.2.11";
in stdenv.mkDerivation {
  name = "${pname}${if withGnome then "-gnome" else ""}-${version}";

  src = fetchFromGitHub {
    owner = "danfruehauf";
    repo = "NetworkManager-ssh";
    rev = "${version}";
    sha256 = "sha256-4mRtPemayCzkmbxCeO3F4b/nqsYrVBTCMaZMfueVRP0=";
  };

  buildInputs = [ networkmanager glib ]
    ++ lib.optionals withGnome [ gtk3 libsecret libnma ];

  nativeBuildInputs = [ intltool pkg-config file ];

  configureFlags = [
    "--without-libnm-glib"
    "--with-gnome=${if withGnome then "yes" else "no"}"
    "--enable-absolute-paths"
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "networkmanager-ssh";
    };
  };

  meta = with lib; {
    description = "NetworkManager's SSH plugin";
    # inherit (networkmanager.meta) maintainers platforms;
    # license = licenses.gpl2Plus;
  };
}
