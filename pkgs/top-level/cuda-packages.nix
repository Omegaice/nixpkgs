{lib, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    final,
    ...
  }: let
    cudaPackageFilter = lib.filterAttrs (n: v: builtins.match "cudaPackages_[[:digit:]]+_[[:digit:]]+" n != null);

    cudaPackages = cudaPackageFilter pkgs;
    cudaPackagesExtension = lib.composeManyExtensions [
      (import ../development/libraries/cub/extension.nix)
    ];
  in {
    overlayAttrs =
      builtins.mapAttrs (
        name: value: value.overrideScope' cudaPackagesExtension
      )
      cudaPackages;
  };
}
