{ lib
, pkgs
}:
let
  cudaPackageFilter = lib.attrsets.filterAttrs (n: v: builtins.match "cudaPackages_[[:digit:]]+_[[:digit:]]+" n != null);

  cudaPackagesExtension = lib.composeManyExtensions ([
    (import ./development/libraries/cub/extension.nix)
  ]);
in
self: super: rec { } // builtins.mapAttrs (name: value: value.overrideScope' cudaPackagesExtension) (cudaPackageFilter super)
