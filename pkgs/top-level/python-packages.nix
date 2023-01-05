{lib, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    final,
    ...
  }: let
    pythonPackages = lib.filterAttrs (n: v: builtins.match "python3[[:digit:]]+?" n != null) final;
  in {
    overlayAttrs = {
      pythonPackagesExtensions =
        pkgs.pythonPackagesExtensions
        ++ [
          (pself: pprev: {
            core-emu = pself.callPackage ../applications/networking/core-emu/default.nix {};
            gevent-eventemitter = pself.callPackage ../development/python-modules/gevent-eventemitter/default.nix {};
            steam = pself.callPackage ../development/python-modules/steam/default.nix {};
          })
        ];
    };
  };
}
