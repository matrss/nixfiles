{ nixpkgs, pulls, ... }:

let
  pkgs = import nixpkgs { };
  mrs = builtins.fromJSON (builtins.readFile pulls);
  mrJobsetFor = mr: {
    enabled = 1;
    hidden = false;
    description = "MR ${mr.iid}: ${mr.title}";
    checkinterval = 60;
    schedulingshares = 20;
    enableemail = false;
    emailoverride = "";
    keepnr = 1;
    type = 1;
    flake = "gitlab:matrss/nixfiles/merge-requests/${mr.iid}/head";
  };
  mrJobsets = pkgs.lib.mapAttrs'
    (name: value: pkgs.lib.nameValuePair ("MR" + name) (mrJobsetFor value))
    mrs;
  jobsets = mrJobsets // {
    main = {
      enabled = 1;
      hidden = false;
      description = "main branch";
      checkinterval = 60;
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 3;
      type = 1;
      flake = "gitlab:matrss/nixfiles/main";
    };
  };
  log = {
    pulls = mrs;
    jobsets = jobsets;
  };
in
{
  jobsets = pkgs.runCommand "spec-jobsets.json" { } ''
    cat > $out << EOF
    ${builtins.toJSON jobsets}
    EOF
    cat > log << EOF
    ${builtins.toJSON log}
    EOF
    ${pkgs.jq}/bin/jq . log
  '';
}
