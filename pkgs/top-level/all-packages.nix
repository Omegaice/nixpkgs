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
    };

    packages = {
      salt-lint = final.salt-lint;
      steamctl = final.steamctl;
      toml-cli = final.toml-cli;
{...}: {
  flake = {
    overlays.all = final: prev: {
      salt-lint = prev.callPackage ../development/tools/salt-lint/default.nix {};
      steamctl = with prev.python3Packages; callPackage ../development/tools/steamctl/default.nix {};
      toml-cli = prev.callPackage ../development/tools/toml-cli/default.nix {};
    };
  };
}
