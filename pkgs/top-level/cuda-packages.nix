final: prev: let
  cudaPackageFilter = prev.lib.filterAttrs (n: v: builtins.match "cudaPackages_[[:digit:]]+_[[:digit:]]+" n != null);

  cudaPackages = cudaPackageFilter prev;
  cudaPackagesExtension = prev.lib.composeManyExtensions [
    (import ../development/libraries/cub/extension.nix)
  ];
in
  builtins.mapAttrs (
    name: value:
      value.overrideScope' cudaPackagesExtension
  )
  cudaPackages
