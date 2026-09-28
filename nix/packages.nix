# The tool this repository ships. Everything else -- dev shell, checks,
# `confirm` -- comes from the set-and-setting standard via mkConsumerFlake.
pkgs:
let
  is-markdown-agentic = pkgs.writeShellApplication {
    name = "is-markdown-agentic";
    text = builtins.readFile ../is-markdown-agentic.sh;
  };
in
{
  default = pkgs.writeShellApplication {
    name = "lefthook-markdownlint-agentic";
    runtimeInputs = [
      pkgs.markdownlint-cli
      is-markdown-agentic
    ];
    text =
      builtins.replaceStrings [ "@MARKDOWNLINT_AGENTIC_CONFIG@" ] [ "${../.markdownlint-agentic.yml}" ]
        (builtins.readFile ../lefthook-markdownlint-agentic.sh);
  };
  inherit is-markdown-agentic;
}
