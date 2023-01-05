{lib, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    final,
    ...
  }: {
    overlayAttrs = {
      salt-lint = pkgs.callPackage ../development/tools/salt-lint/default.nix {};
      steamctl = pkgs.callPackage ../development/tools/steamctl/default.nix {};
      toml-cli = pkgs.callPackage ../development/tools/toml-cli/default.nix {};
      vermin = pkgs.callPackage ../development/tools/vermin/default.nix {};
    };

    packages = {
      salt-lint = final.salt-lint;
      steamctl = final.steamctl;
      toml-cli = final.toml-cli;
      vermin = final.vermin;
    };
  };
}
