{
  lib,
  buildPythonPackage,
  fetchPypi,
  python3Packages,
}:

buildPythonPackage rec {
  pname = "mbed-tools";
  version = "7.58.0"; # example

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    pyserial
    intelhex
    prettytable
    packaging
    cmsis-pack-manager
  ];

  doCheck = false;

  meta = with lib; {
    description = "Arm Mbed command line tools";
    homepage = "https://github.com/ARMmbed/mbed-tools";
    license = licenses.asl20;
  };
}
