{ stdenv, fetchurl, libX11 }:

stdenv.mkDerivation rec {
  pname = "xplot";
  version = "0.90.7.1";

  src = fetchurl {
    url = "http://www.xplot.org/xplot/xplot-${version}.tar.gz";
    sha256 = "sha256-Ac6sRVQPLQHm/+NozA6VD0u3/h0jXv3lNJoJGZ5mIkA=";
  };

  buildInputs = [ libX11 ];

  meta = with lib;
    {
      # homepage = "https://github.com/efernau/rot8";
      # description =
      #   "Automatic display rotation using built-in accelerometer for sway and X11.";
      # license = licenses.mit;
      # maintainers = [ ];
    };
}
