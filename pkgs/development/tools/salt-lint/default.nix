{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "salt-lint";
  version = "0.8.0";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "warpnet";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-V0T9VvtLurruOL808hR8GiNBU4e7HjB6vCvXH14m4xs=";
  };

  propagatedBuildInputs = with python3Packages; [
    pyyaml
    pathspec
  ];

  meta = with lib; {
    homepage = "https://github.com/warpnet/salt-lint";
    changelog = "https://github.com/warpnet/salt-lint/blob/v${version}/CHANGELOG.md";
    description = "A command-line utility that checks for best practices in SaltStack.";
    license = licenses.mit;
  };
}
