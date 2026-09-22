{
  description = "Lefthook-compatible typos spell checker packaged as a Nix flake";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lock = {
      url = "github:pr0d1r2/nixpkgs-lock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    set-and-setting = {
      url = "github:pr0d1r2/set-and-setting";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-lock.follows = "nixpkgs-lock";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
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
                nixpkgs.legacyPackages.${system}.bats
                nixpkgs.legacyPackages.${system}.taplo
                consumer.packages.${system}.lefthook-typos
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
            "toml"
          ];
          src = ./.;
          extraPackages = pkgs: {
            default = pkgs.writeShellApplication {
              name = "lefthook-typos";
              runtimeInputs = [ pkgs.typos ];
              text = builtins.readFile ./lefthook-typos.sh;
            };
            lefthook-typos = pkgs.writeShellApplication {
              name = "lefthook-typos";
              runtimeInputs = [ pkgs.typos ];
              text = builtins.readFile ./lefthook-typos.sh;
            };
          };
        }
      );
}
