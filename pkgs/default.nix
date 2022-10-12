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
      salt-lint = overlay-super.callPackage ./development/tools/salt-lint/default.nix {};

      pythonPackagesExtensions = overlay-super.pythonPackagesExtensions ++ [(import ./top-level/python-packages.nix)];

      # nixosTests = {
      #   inherit (overlay-super) nixosTests;
      #   core-emu = nixosTest ../nixos/tests/core-emu.nix;
      # };
      nixosTests =
        overlay-super.nixosTests
        // {
          core-emu = overlay-super.nixosTest ../nixos/tests/core-emu.nix;
        };
    }
    // builtins.mapAttrs (name: value: value.overrideScope' cudaPackagesExtension) (cudaPackageFilter overlay-super)
