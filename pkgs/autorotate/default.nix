{ stdenv }:

stdenv.mkDerivation rec {
  pname = "autorotate";
  version = "0.0.0";
  # version = "master";

  src = ./.;

  buildInputs = [ ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/autorotate $out/bin
  '';

  meta = with stdenv.lib;
    {
      # homepage = "";
      # description = "";
      # license = licenses.mit;
      # maintainers = [ ];
    };
}
