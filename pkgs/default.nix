{
  lib,
  pkgs,
}: let
  cudaPackageFilter = lib.attrsets.filterAttrs (n: v: builtins.match "cudaPackages_[[:digit:]]+_[[:digit:]]+" n != null);
  cudaPackagesExtension = lib.composeManyExtensions [
    (import ./development/libraries/cub/extension.nix)
  ];
in
  overlay-self: overlay-super:
    rec {
      ospf-mdr = overlay-super.callPackage ./applications/networking/ospf-mdr/default.nix {};
      emane = overlay-super.callPackage ./applications/networking/emane/default.nix {};

      pythonPackagesExtensions =
        overlay-super.pythonPackagesExtensions
        ++ [
          (python-final: python-prev: {
            emane = python-prev.toPythonModule (overlay-self.emane.override {
              python3 = python-prev.python;
            });
          })
        ];
    }
    // builtins.mapAttrs (name: value: value.overrideScope' cudaPackagesExtension) (cudaPackageFilter overlay-super)
