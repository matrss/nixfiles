{ python3, fetchPypi }:

python3.pkgs.buildPythonApplication rec {
  pname = "smtp2paperless";
  version = "0.0.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Yfn08qgrgbQixTFNGqotQYskUxyjRrGGHwyLmTuwnYQ=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiosmtpd
    requests
  ];
}
