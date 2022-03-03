{ buildPythonPackage
, isPy38
, fetchPypi
, datalad
, requests
, nose
, git
, git-annex
, singularity
}:

buildPythonPackage rec {
  pname = "datalad-container";
  version = "1.1.5";

  disabled = !isPy38;

  src = fetchPypi {
    inherit version;
    pname = "datalad_container";
    sha256 = "sha256-9gmaASTdsvAhUx1QIKWD7KPNkkPk5gmw9Y4/cud5tgE=";
  };

  propagatedBuildInputs = [ datalad requests ];

  checkInputs = [ nose git git-annex singularity datalad ];

  checkPhase = ''
    python -m nose --traverse-namespace -s -v -e "test_docker" datalad_container
  '';
}
