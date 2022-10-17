{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "toml-cli";
  version = "0.3.1";
  format = "pyproject";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "mrijken";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0xMreYcssZOv21MZqPcYW8IZRW5JzZ47W8iE1xiPa9g=";
  };

  propagatedBuildInputs = with python3Packages; [
    poetry
    typer
    tomlkit
    regex
  ];

  meta = with lib; {
    homepage = "https://github.com/mrijken/toml-cli";
    changelog = "https://github.com/mrijken/toml-cli/blob/v${version}/CHANGELOG.md";
    description = "Command line interface for toml files.";
    license = licenses.mit;
  };
}
