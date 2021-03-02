final: prev:

{
  conda = prev.conda.overrideAttrs (old: { runScript = "zsh"; });
}
