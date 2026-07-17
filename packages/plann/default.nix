{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "plann";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pycalendar";
    repo = "plann";
    rev = "v${version}";
    hash = "sha256-WJ7uSYk/esMTjNGAXkjSfqBoxbkOv28tL+PjFc3fwVk=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    caldav
    click
    pyyaml
    sortedcontainers
    tzlocal
  ];

  pythonImportsCheck = [ "plann" ];

  meta = {
    description = "Command-line CalDAV client for calendars and tasks";
    homepage = "https://github.com/pycalendar/plann";
    license = lib.licenses.gpl3Plus;
    mainProgram = "plann";
  };
}
