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
        ./pkgs/top-level/all-packages.nix
        ./pkgs/top-level/cuda-packages.nix
        ./pkgs/top-level/python-packages.nix
      ];
      perSystem = {
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

        addedPackages = builtins.map (e: {"${e}" = pkgs."${e}";}) (lib.lists.subtractLists (builtins.attrNames nixPkgs) (builtins.attrNames pkgs));
        packages = lib.lists.foldl (a: b: a // b) {} addedPackages;
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = lib.attrsets.mapAttrsToList (n: v: v) self.overlays;
        };

        inherit packages;

        formatter = inputs'.nixpkgs.legacyPackages.alejandra;
      };
      flake = {config, ...}: {};
    };
}
