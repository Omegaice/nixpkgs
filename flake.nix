{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let

      in
      {
        overlay = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/default.nix {
          inherit (nixpkgs) lib pkgs;
        };

        packages = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # For CUDA packages
          overlays = [
            self.overlay.${system}
          ];
        };
      }
    );
}
