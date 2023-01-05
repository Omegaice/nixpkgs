{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "vermin";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "netromdk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-PG6g1FFivkYgI9V/a+yUk7BOPd2ck7ISNLUiatS+/to=";
  };

  propagatedBuildInputs = with python3Packages; [];

  meta = with lib; {
    homepage = "https://github.com/netromdk/vermin";
    changelog = "https://github.com/netromdk/vermin/releases/tag/v${version}";
    description = "Concurrently detect the minimum Python versions needed to run code - Vermin 1.6 will end support for running via Python 2.7. Python 3.x is going to be required but detection of 2.x functionality will remain functional.";
    license = licenses.mit;
  };
}
