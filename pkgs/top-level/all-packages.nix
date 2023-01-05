{...}: {
  flake = {
    overlays.all = final: prev: {
      salt-lint = prev.callPackage ../development/tools/salt-lint/default.nix {};
      steamctl = with prev.python3Packages; callPackage ../development/tools/steamctl/default.nix {};
      toml-cli = prev.callPackage ../development/tools/toml-cli/default.nix {};
    };
  };
}
