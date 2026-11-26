{
  alsa-lib,
  at-spi2-core,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  expat,
  fetchurl,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "terminal-browser";
  version = "0.16.1";

  src = fetchurl {
    url = "https://terminal-browser.sh/install/dl/stable/v${version}/terminal-browser-linux-x64.tar.gz";
    sha256 = "f5179f6fa22dedc29ab35059c88705c815a8af463d310c6312f2bab971b57a58";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    stdenv.cc.cc.lib
  ];
  runtimeDependencies = [gtk3];

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/libexec/terminal-browser"
    cp -r . "$out/libexec/terminal-browser"
    ln -s ../libexec/terminal-browser/bin/terminal-browser "$out/bin/terminal-browser"
    runHook postInstall
  '';

  meta = {
    description = "Chromium browser rendered inside a terminal";
    homepage = "https://terminal-browser.sh";
    mainProgram = "terminal-browser";
    platforms = ["x86_64-linux"];
  };
}
