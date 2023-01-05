{
  description = "";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        flake-parts.flakeModules.easyOverlay
        ./pkgs/top-level/all-packages.nix
        ./pkgs/top-level/cuda-packages.nix
        ./pkgs/top-level/python-packages.nix
      ];
      perSystem = {
        self',
        inputs',
        system,
        lib,
        pkgs,
        ...
      }: let
        nixPkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        _module.args.pkgs = nixPkgs;

        checks = builtins.mapAttrs (name: value: value.overrideAttrs (old: {doCheck = true;})) self'.packages;

        formatter = inputs'.nixpkgs.legacyPackages.alejandra;
      };
    };
}
