{
  self,
  nixpkgs,
  set-and-setting,
}:
let
  supportedSystems = [
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];
  forAllSystems =
    f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

  fragments = [
    "base"
    "nix"
    "shell"
    "actions"
    "ascii"
    "markdown"
    "yaml"
  ];
in
{
  packages = forAllSystems (
    pkgs:
    let
      is-markdown-agentic = pkgs.writeShellApplication {
        name = "is-markdown-agentic";
        text = builtins.readFile ../is-markdown-agentic.sh;
      };
    in
    {
      setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;
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
  );

  devShells = forAllSystems (
    pkgs:
    let
      mat = set-and-setting.lib.materializationFor { inherit pkgs fragments; };
      sys = pkgs.stdenv.hostPlatform.system;
      localWrapper = self.packages.${sys}.default;
      packages = builtins.filter (p: p.name or "" != "lefthook-markdownlint-agentic") mat.packages ++ [
        localWrapper
      ];
    in
    set-and-setting.lib.mkDevShells {
      inherit pkgs;
      basePackages = packages;
      settingHook = ''
        ${self.packages.${sys}.setting}/bin/sync-setting .
        _assemble_out="$(mktemp -d)"
        FRAGMENTS="${builtins.concatStringsSep " " fragments}" \
          out="$_assemble_out" \
          FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook" \
          bash "${set-and-setting}/setting/lib/assemble-lefthook.sh"
        cp -f "$_assemble_out/lefthook.yml" lefthook.yml
        rm -rf "$_assemble_out"
      '';
    }
  );

  checks = forAllSystems (
    pkgs:
    (set-and-setting.lib.checksFor {
      inherit pkgs fragments;
      src = ../.;
    })
    // {
      dep-graph = set-and-setting.lib.mkDepGraphCheck {
        inherit pkgs;
        projectRoot = ../.;
      };
      default = pkgs.runCommand "checks" { } "touch $out";
    }
  );

  apps = forAllSystems (
    pkgs:
    let
      mat = set-and-setting.lib.materializationFor { inherit pkgs fragments; };
      sys = pkgs.stdenv.hostPlatform.system;
      localWrapper = self.packages.${sys}.default;
      packages = builtins.filter (p: p.name or "" != "lefthook-markdownlint-agentic") mat.packages ++ [
        localWrapper
      ];
    in
    {
      confirm = {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            name = "confirm";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.diffutils
              pkgs.findutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ]
            ++ packages;
            text = ''
              bash ${../confirm.sh} \
                "${set-and-setting}/setting/integrations/lefthook" \
                "${set-and-setting}/setting/lib/assemble-lefthook.sh" \
                "${set-and-setting}/setting/lib/detect-fragments.sh" \
                "${self.packages.${pkgs.stdenv.hostPlatform.system}.setting}" \
                "${set-and-setting}/lib/confirm.sh" \
                "${set-and-setting.rev or "unknown"}"
            '';
          }
        }/bin/confirm";
      };
    }
  );
}
