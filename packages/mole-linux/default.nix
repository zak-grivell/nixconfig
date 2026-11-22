{
  stdenvNoCC,
  fetchurl,
  lib,
  makeWrapper,
  coreutils,
  curl,
  findutils,
  gawk,
  gnugrep,
  gnused,
  procps,
  util-linux,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mole-linux";
  version = "0.7.1";
  src = fetchurl {
    url = "https://github.com/tw93/Mole/releases/download/V${finalAttrs.version}-linux/mole-${finalAttrs.version}-linux-x86_64.tar.gz";
    sha256 = "4a06624d3060387b4b136976667571e7e1668849e51ff4b1aded94969dac2b6c";
  };

  nativeBuildInputs = [makeWrapper];

  postPatch = ''
    substituteInPlace mole --replace-fail /bin/pwd ${coreutils}/bin/pwd
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/libexec/mole"
    cp -r mole VERSION bin lib "$out/libexec/mole/"
    patchShebangs "$out/libexec/mole"
    makeWrapper "$out/libexec/mole/mole" "$out/bin/mole" \
      --prefix PATH : ${lib.makeBinPath [coreutils curl findutils gawk gnugrep gnused procps util-linux]}
    ln -s mole "$out/bin/mo"
    runHook postInstall
  '';

  meta = {
    description = "Mole desktop maintenance CLI for Linux";
    homepage = "https://github.com/tw93/Mole";
    mainProgram = "mole";
    platforms = ["x86_64-linux"];
  };
})
