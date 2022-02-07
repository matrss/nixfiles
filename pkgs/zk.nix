{ buildGoModule, fetchFromGitHub, icu }:

let
  version = "0.5.0";
in
buildGoModule {
  pname = "zk";
  inherit version;

  src = fetchFromGitHub {
    owner = "mickael-menu";
    repo = "zk";
    rev = "v${version}";
    hash = "sha256-EFVNEkBYkhArtUfULZVRPxFCVaPHamadqFxi7zV7y8g=";
  };

  buildInputs = [ icu ];

  tags = [ "icu" "fts5" ];

  proxyVendor = true;

  vendorSha256 = "sha256-Ez31wKe1XkyKu9ieKbY4r9eV2CCONvUT+YNbD0+vSkQ=";

  doCheck = false;
}
