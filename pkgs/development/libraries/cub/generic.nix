{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  autoAddOpenGLRunpathHook,
  cudatoolkit,
  cmake,
}: {
  fullVersion,
  sha256,
  includedIn ? "",
}:
assert lib.assertMsg (builtins.compareVersions cudatoolkit.version includedIn != 0) "This version of CUB is already included in cuda toolkit ${cudatoolkit.version}";
  stdenv.mkDerivation rec {
    pname = "cub";
    version = fullVersion;

    src = fetchFromGitHub {
      owner = "NVIDIA";
      repo = pname;
      rev = version;
      inherit sha256;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      autoAddOpenGLRunpathHook
      cmake
    ];

    buildInputs = [
      cudatoolkit
    ];

    cmakeFlags = [
      "-DCUB_ENABLE_HEADER_TESTING=OFF"
      "-DCUB_ENABLE_TESTING=OFF"
      "-DCUB_ENABLE_EXAMPLES=OFF"
    ];

    meta = with lib; {
      homepage = "https://docs.nvidia.com/cuda/cub/index.html";
      description = "CUB provides state-of-the-art, reusable software components for every layer of the CUDA programming model.";
      license = licenses.bsd3;
    };
  }
