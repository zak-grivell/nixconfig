{appimageTools, fetchurl}: let
  pname = "helium";
  version = "0.22.2.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    sha256 = "f090c811253fd68bc7eb894b982a0be221d1701f77ed4b53f6146499af8bae04";
  };
  contents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -Dm644 ${contents}/helium.desktop "$out/share/applications/helium.desktop"
      cp -r ${contents}/usr/share/icons "$out/share/"
    '';
  }
