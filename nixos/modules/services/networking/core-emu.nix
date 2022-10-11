{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.core-emu;
in {
  options.services.core-emu = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        CORE Emulation daemon service.
      '';
    };
  };

  config = {
    systemd.services.core-daemon = {
      description = "Common Open Research Emulator Service";
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.core-emu}/bin/core-daemon
        '';
      };
      wantedBy = ["multi-user.target"];
      path = [pkgs.core-emu];
    };
  };
}
