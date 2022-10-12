final: prev: {
  nixosTests =
    prev.nixosTests
    // {
      core-emu = prev.nixosTest ./core-emu.nix;
    };
}
