{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "looseversion";
  version = "1.0.3";
  format = "flit";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-A1KIhg4a/mfWPqnHAN2dCVxyTi5XIqOQKd2RZS1DFu0=";
  };
}
