{
  lib,
  buildPythonPackage,
  isPy3k,
  fetchFromGitHub,
  pytestCheckHook,
  gevent,
}:
buildPythonPackage rec {
  pname = "gevent-eventemitter";
  version = "2.1";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "rossengeorgiev";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-aW4OsQi3N5yAMdbTd8rxbb2qYMfFJBR4WQFIXvxpiMw=";
  };

  propagatedBuildInputs = [gevent];

  checkInputs = [pytestCheckHook];
  pythonImportsCheck = ["eventemitter"];
}
