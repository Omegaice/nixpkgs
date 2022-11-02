{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    {
      overlays = {
        default = import ./pkgs/default.nix;
        tests = import ./nixos/tests/default.nix;
        main = import ./pkgs/top-level/all-packages.nix;
        cuda = import ./pkgs/top-level/cuda-packages.nix;
        python = import ./pkgs/top-level/python-packages.nix;
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # For CUDA packages
          overlays = [
            self.overlays.main
            self.overlays.tests
            self.overlays.python
            self.overlays.cuda
          ];
        };
        inherit (pkgs) lib;
        overlayAttrs = builtins.attrNames (import ./pkgs/default.nix pkgs pkgs);
      in {
        packages = pkgs;
      }
    );
}
