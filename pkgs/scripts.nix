{
  dply = { writeShellApplication, nixos-rebuild }: writeShellApplication {
    name = "dply";
    runtimeInputs = [ nixos-rebuild ];
    text = ''
      nixos-rebuild switch --flake .#"$1" --target-host "root@$1"
    '';
  };

  drv-path = { writeShellApplication, jq }: writeShellApplication {
    name = "drv-path";
    runtimeInputs = [ jq ];
    text = ''
      nix path-info --json --derivation .#nixosConfigurations.\""$1"\".config.system.build.toplevel |
        jq '{ "path": .[0].path }'
    '';
  };

  generate-hostnames = { writeShellApplication, python3 }: writeShellApplication {
    name = "generate-hostnames";
    runtimeInputs = [ python3 ];
    text = ''
      python3 << EOF
      import string
      import random

      columns = 5

      for i in range(100):
          print("".join(random.choices(string.ascii_lowercase, k=6)), end="\n" if i % columns == (columns-1) else "\t")
      EOF
    '';
  };

  lint.vulnix = { writeShellApplication, vulnix }: writeShellApplication {
    name = "lint.vulnix";
    runtimeInputs = [ vulnix ];
    text = ''
      nix build .#nixosConfigurations."$1".config.system.build.toplevel
      vulnix result
    '';
  };

  ci = { writeShellApplication, jq }: writeShellApplication {
    name = "ci";
    runtimeInputs = [ jq ];
    text = ''
      nix flake check
      nix flake show --json | jq -r '.nixosConfigurations | keys | join("\n")' | while IFS=$'\n' read -r hostname; do
        echo "$hostname":
        nix run .#lint.vulnix "$hostname" || true
        nix build .#nixosConfigurations."$hostname".config.system.build.toplevel
      done
    '';
  };
}
