{ stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "pier";
  version = "master";

  src = fetchFromGitHub {
    owner = "pier-cli";
    repo = "pier";
    rev = "${version}";
    sha256 = "sha256-nh8r9jZ+wC/SrxhnUiOBwHt+FkbedWYvokmCwDKjQ0g=";
  };

  cargoSha256 = "sha256-MYmQ2L9VMku3Lo7tagonIszjJvXvqWuIH9TBc5DTpKk=";

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://github.com/pier-cli/pier";
    description = "A Linux script management CLI written in Rust";
    license = licenses.mit;
    maintainers = [ ];
  };
}
