{ stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "pier";
  version = "master";

  src = fetchFromGitHub {
    owner = "pier-cli";
    repo = "pier";
    rev = "${version}";
    sha256 = "sha256-DTPYUnajcjWR+lytCr55p4p7jeLj8sQPSRc14jXEbA8=";
  };

  cargoSha256 = "sha256-hgDnqnfr65Kg3pq7FpBwU4nT9c7xJcOiGXvNJQDUHJg=";

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://github.com/pier-cli/pier";
    description = "A Linux script management CLI written in Rust";
    license = licenses.mit;
    maintainers = [ ];
  };
}
