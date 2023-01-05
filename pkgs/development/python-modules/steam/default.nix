{
  lib,
  buildPythonPackage,
  isPy3k,
  fetchFromGitHub,
  pythonRelaxDepsHook,
  pytestCheckHook,
  six,
  pycryptodomex,
  vdf,
  requests,
  cachetools,
  protobuf,
  gevent-eventemitter,
  vcrpy,
  mock,
}:
buildPythonPackage rec {
  pname = "steam";
  version = "1.4.3";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "ValvePython";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-yXujem6lpkyOAeuTGgRcRN0G8rADp+xjvP+B9dZT0bg=";
  };

  nativeBuildInputs = [pythonRelaxDepsHook];
  pythonRelaxDeps = ["protobuf"];

  propagatedBuildInputs = [six pycryptodomex vdf requests cachetools];

  passthru.optional-dependencies = {
    client = [protobuf gevent-eventemitter];
  };

  checkInputs = [pytestCheckHook mock vcrpy] ++ passthru.optional-dependencies.client;
  pythonImportsCheck = ["steam"];
}
