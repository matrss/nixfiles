{
  dply = { writeShellApplication, nixos-rebuild }: writeShellApplication {
    name = "dply";
    runtimeInputs = [ nixos-rebuild ];
    text = ''
      nixos-rebuild switch --flake .#"$1" --target-host "root@$1" --use-substitutes
    '';
  };

  nixos-config-path = { writeShellApplication, jq }: writeShellApplication {
    name = "nixos-config-path";
    runtimeInputs = [ jq ];
    text = ''
      nix path-info --json .#nixosConfigurations.\""$1"\".config.system.build.toplevel |
        jq 'to_entries | { "path": .[0].key }'
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
}
