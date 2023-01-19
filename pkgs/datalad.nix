{ buildPythonPackage
, argcomplete
, installShellFiles
, fetchPypi
, pythonRelaxDepsHook
, distro
, platformdirs
, packaging
, wrapt
, requests
, msgpack
, whoosh
, simplejson
, keyrings-alt
, PyGithub
, looseversion
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
, chardet
, git-annex
, python-gitlab
, mutagen
, exifread
, pillow
, python-xmp-toolkit
, pypandoc
, psutil
, pytestCheckHook
, nose
, git
, openssh
, p7zip
}:

buildPythonPackage rec {
  pname = "datalad";
  version = "0.18.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2mmYXfcNV6RJLqK3WH7nKPGq2q/+SfPwN5gWQzXF9Eg=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook installShellFiles git ];

  pythonRelaxDeps = [ "chardet" ];

  buildInputs = [ pypandoc ];

  propagatedBuildInputs = [
    git-annex
    distro
    platformdirs
    packaging
    mutagen
    exifread
    pillow
    python-xmp-toolkit
    looseversion
    psutil
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
    chardet
    argcomplete
  ];

  postInstall = ''
    $out/bin/datalad shell-completion
    installShellCompletion --cmd datalad \
      --bash <($out/bin/datalad shell-completion) \
      --zsh  <($out/bin/datalad shell-completion)
  '';

  checkInputs = [ pytestCheckHook nose git git-annex openssh p7zip ];

  preCheck = ''
    export DATALAD_TESTS_NONETWORK=1
    export HOME=$(mktemp -d)
    export PATH="$out/bin:$PATH"
  '';

  # Disable some very slow tests
  pytestFlagsArray = [
    "-m 'not turtle and not slow'"
  ];

  # These tests simply did not work in nixpkgs, not sure why exactly
  disabledTests = [
    "test_reckless"
    "test_fetch_git_special_remote"
    "test_create"
    "test_initremote_basic_httpsurl"
    "test_url_keys"
    "test_addurls"
    "test_drop_after"
    "test_copy_file"
    "test_AnnexRepo_web_remote"
    "test_AnnexRepo_addurl_to_file_batched"
    "test_annexrepo_fake_dates_disables_batched"
    "test_as_common_datasource"
    "test_shell_completion_source"
    "test_add_archive_dirs"
    "test_add_archive_content"
    "test_add_archive_content_strip_leading"
    "test_AnnexRepo_backend_option"
    "test_is_available"
    "test_AnnexRepo_addurl_batched_and_set_metadata"
    "test_report_absent_keys"
    "test_BasicAnnexTestRepo"
    "test_get_open_files"
  ];

  pythonImportsCheck = [ "datalad" ];
}
