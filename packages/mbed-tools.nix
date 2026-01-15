{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "mbed-tools";
  version = "7.58.0"; # example

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-tFMpKkb1z86eYboQxPGbhVLBrUzx5xOVwXCieeXYHB0==";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    pyserial
    intelhex
    prettytable
    packaging
    cmsis-pack-manager
    python-dotenv
    gitpython
    tqdm
    tabulate
    requests
    jinja2
    setuptools
  ];

  pyproject = true;

  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
  ];

  doCheck = false;

  meta = with lib; {
    description = "Arm Mbed command line tools";
    homepage = "https://github.com/ARMmbed/mbed-tools";
    license = licenses.asl20;
  };
}
