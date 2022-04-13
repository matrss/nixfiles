{ buildPythonPackage
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
  version = "1.1.6";

  src = fetchPypi {
    inherit version;
    pname = "datalad_container";
    sha256 = "sha256-iNco1jeyNl4st2E0m+bsfNG1/2Gx4PibRhbSIN6VfhM=";
  };

  propagatedBuildInputs = [ datalad requests ];

  checkInputs = [ nose git git-annex singularity datalad ];

  checkPhase = ''
    python -m nose --traverse-namespace -s -v -e "test_docker" -e "test_ensure_datalad_remote_maybe_enable" -e "test_ensure_datalad_remote_init_and_enable_needed" -e "test_custom_call_fmt" -e "test_add_local_path" -e "test_add_noop" -e "test_container_files" -e "test_container_from_subdataset" -e "test_container_update" -e "test_list_contains" -e "test_find_containers" -e "test_run_mispecified" -e "test_run_unknown_cmdexec_placeholder" -e "test_run_subdataset_install" datalad_container
  '';

  pythonImportsCheck = [ "datalad_container" ];
}
