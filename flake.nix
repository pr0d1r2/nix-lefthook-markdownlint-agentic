{
  description = "CHANGEME";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting.url = "github:pr0d1r2/set-and-setting";
    set-and-setting.inputs.nixpkgs-lock.follows = "nixpkgs-lock";
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    # The standard's shells, plus the linter this tool drives: the specs run
    # the repository's own wrapper (tests/unit/local-tools.bash), which calls
    # `markdownlint` from PATH. Added, not replaced -- confirm, checks and the
    # materialized lefthook.yml stay the standard's.
    (
      consumer:
      consumer
      // {
        devShells = builtins.mapAttrs (
          system: shells:
          builtins.mapAttrs (
            _name: shell:
            shell.overrideAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [
                nixpkgs.legacyPackages.${system}.markdownlint-cli
              ];
            })
          ) shells
        ) consumer.devShells;
      }
    )
      (
        set-and-setting.lib.mkConsumerFlake {
          inherit self nixpkgs set-and-setting;
          fragments = [
            "base"
            "nix"
            "shell"
            "ascii"
            "markdown"
            "yaml"
          ];
          src = ./.;
          extraPackages = import ./nix/packages.nix;
        }
      );
}
