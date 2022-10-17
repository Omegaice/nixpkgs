final: prev: {
  core-emu = with prev.python3Packages; toPythonApplication core-emu;
  emane = prev.callPackage ../applications/networking/emane/default.nix {};
  ospf-mdr = prev.callPackage ../applications/networking/ospf-mdr/default.nix {};
  salt-lint = prev.callPackage ../development/tools/salt-lint/default.nix {};
  toml-cli = prev.callPackage ../development/tools/toml-cli/default.nix {};
}
