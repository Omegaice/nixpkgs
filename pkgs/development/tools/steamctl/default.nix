{
  lib,
  buildPythonApplication,
  isPy3k,
  fetchFromGitHub,
  arrow,
  beautifulsoup4,
  vpk,
  pyqrcode,
  steam,
  appdirs,
  argcomplete,
  tqdm,
  pytestCheckHook,
}:
buildPythonApplication rec {
  pname = "steamctl";
  version = "0.9.5";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "ValvePython";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-reNch5MP31MxyaeKUlANfizOXZXjtIDeSM1kptsWqkc=";
  };

  propagatedBuildInputs =
    [
      arrow
      beautifulsoup4
      vpk
      pyqrcode
      steam
      appdirs
      argcomplete
      tqdm
    ]
    ++ steam.optional-dependencies.client;
}
