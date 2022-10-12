final: prev: let
  inherit (final) callPackage;
  inherit (prev) cudatoolkit cudaVersion lib pkgs;

  buildCubPackage = args: callPackage ./generic.nix {} args;

  toUnderscore = str: lib.replaceStrings ["."] ["_"] str;

  cubPackages = with lib; let
    computeName = version: "cub_${toUnderscore version}";

    allBuilds =
      mapAttrs'
      (
        version: file:
          nameValuePair (computeName version) (callPackage ./generic.nix {} (builtins.head file))
      )
      cubVersions;

    defaultBuild = {
      "cub" = allBuilds.${computeName cubDefaultVersion};
    };
  in
    allBuilds // defaultBuild;

  cubVersions = {
    "1.10.0" = [
      rec {
        fullVersion = "1.10.0";
        sha256 = "sha256-JyyNaTrtoSGiMP7tVUu9lFL07lyfJzRTVtx8yGy6/BI=";
        includedIn = "11.2";
      }
    ];
  };

  cubDefaultVersion = "1.10.0";
in
  cubPackages
