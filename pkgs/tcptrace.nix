{ stdenv, fetchurl, libpcap }:

stdenv.mkDerivation rec {
  pname = "tcptrace";
  version = "6.6.7";

  src = fetchurl {
    url = "http://www.tcptrace.org/download/tcptrace-${version}.tar.gz";
    sha256 = "sha256-YzgKQFGTPKCJeUdqnfxvlZMIvJ9g1FJVIC44jrVpEL0=";
  };

  buildInputs = [ libpcap ];

  configureFlags = [ "--with-libpcap=${libpcap}" ];

  meta = with stdenv.lib;
    {
      # homepage = "https://github.com/efernau/rot8";
      # description =
      #   "Automatic display rotation using built-in accelerometer for sway and X11.";
      # license = licenses.mit;
      # maintainers = [ ];
    };
}
