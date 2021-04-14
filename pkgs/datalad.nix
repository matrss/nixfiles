{ python3Packages
, buildPythonPackage
, fetchPypi
, wrapt
, requests
, msgpack
, whoosh
, simplejson
, keyrings-alt
, PyGithub
, boto
, keyring
, jsmin
, fasteners
, humanize
, appdirs
, annexremote
, tqdm
, patool
, iso8601
, setuptools
, git-annex
, python-gitlab
, mutagen
, exifread
, pillow
, python-xmp-toolkit
, pypandoc
, nose
}:

let
  datalad-container = buildPythonPackage rec {
    pname = "datalad-container";
    version = "1.1.2";

    src = fetchPypi {
      inherit version;
      pname = "datalad_container";
      sha256 = "sha256-0zvgl0RmWbcn/08qZ51Gx4HPoBgwm2+mK9oxuXZ7lmM=";
    };

    checkInputs = [ nose ];

    propagatedBuildInputs = [ requests ];

    preBuild = ''
      sed -i '/datalad>=.*/d' setup.py
    '';

    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "datalad";
  version = "0.14.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2hV+yb3oNOzO/tMNUo4tZGd2jZx13TCM8iG50VEIOWM=";
  };

  buildInputs = [ pypandoc ];

  propagatedBuildInputs = [
    datalad-container
    git-annex
    mutagen
    exifread
    pillow
    python-xmp-toolkit
    wrapt
    requests
    msgpack
    whoosh
    simplejson
    keyrings-alt
    PyGithub
    boto
    keyring
    jsmin
    fasteners
    humanize
    appdirs
    annexremote
    python-gitlab
    tqdm
    patool
    iso8601
    setuptools
  ];

  doCheck = false;
}
