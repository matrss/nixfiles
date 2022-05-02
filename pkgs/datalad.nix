{ buildPythonPackage
, fetchPypi
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
, git
, openssh
}:

buildPythonPackage rec {
  pname = "datalad";
  version = "0.16.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-H6stkrvRtoPuhkA6xjeVp1kgjUPX/yyC6SjGPyFP+HY=";
  };

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

  checkInputs = [ nose git git-annex openssh ];

  doCheck = false;

  checkPhase = ''
    make bin
    export PATH="$PWD/bin:$PATH"
    python -m nose --traverse-namespace -s -v -e "test_cfg_override" -e "test_commanderror_jsonmsgs" -e "test_autoenabled_remote_msg" -e "test_clone_crcns" -e "test_clone_datasets_root" -e "test_gin_cloning" -e "test_ria_http_storedataladorg" -e "test_reckless" -e "test_clone_dataset_from_just_source" -e "test_clone_simple_local" -e "test_nonuniform_adjusted_subdataset" -e "test_create" -e "test_url_keys" -e "test_binary_data" -e "test_failed_install_multiple" -e "test_install_datasets_root" -e "test_install_recursive_github" -e "test_datasets_datalad_org" -e "test_install_dataset_from_just_source" -e "test_install_dataset_from_just_source_via_path" -e "test_install_simple_local" -e "test_remove_recursive_2" -e "test_deny_access" -e "test_add_archive_single_file" -e "test_download_url_need_datalad_remote" -e "test_shell_completion_source" -e "test_protocols" -e "test_compress_dir" -e "test_get_versioned_url_anon" -e "test_clone" -e "test_cached_dataset" -e "test_cached_url" -e "test_get_cached_dataset" -e "test__version__" -e "test_download_url_exceptions" datalad
  '';
}
