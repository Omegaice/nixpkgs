final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pself: pprev: {
        core-emu = pself.callPackage ../applications/networking/core-emu/default.nix {};
      })
    ];
}
