{
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
