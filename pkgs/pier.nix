{ stdenv, lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "pier";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "pier-cli";
    repo = "pier";
    rev = "v${version}";
    sha256 = "sha256-DTPYUnajcjWR+lytCr55p4p7jeLj8sQPSRc14jXEbA8=";
  };

  cargoSha256 = "sha256-cpP8iMsPP727Uifa6NVMtRWRiq09QalpnbN1lYMsg34=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/pier-cli/pier";
    description = "A Linux script management CLI written in Rust";
    license = licenses.mit;
    maintainers = [ ];
  };
}
