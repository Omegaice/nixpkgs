{...}: {
  flake = {
    overlays.python = final: prev: {
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
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
