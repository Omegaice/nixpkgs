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
    {
      core-emu = with overlay-super.python3Packages; toPythonApplication core-emu;
      emane = overlay-super.callPackage ./applications/networking/emane/default.nix {};
      ospf-mdr = overlay-super.callPackage ./applications/networking/ospf-mdr/default.nix {};

      pythonPackagesExtensions = overlay-super.pythonPackagesExtensions ++ [(import ./top-level/python-packages.nix)];
    }
    // builtins.mapAttrs (name: value: value.overrideScope' cudaPackagesExtension) (cudaPackageFilter overlay-super)
