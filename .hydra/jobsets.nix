{ nixpkgs, ... }:

let
  pkgs = import nixpkgs { };
  jobsets = {
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
in
{
  jobsets = pkgs.runCommand "spec-jobsets.json" { } ''
    cat > $out <<EOF
    ${builtins.toJSON jobsets}
    EOF
  '';
}
