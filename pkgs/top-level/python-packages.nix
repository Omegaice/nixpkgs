self: super:
with self;
with super; {
  core-emu = callPackage ../applications/networking/core-emu/default.nix {};

  # emane = super.toPythonModule (pkgs.emane.override {
  #   python3 = super.python;
  # });
}
