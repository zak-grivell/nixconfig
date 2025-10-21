{
  fetchgit,
  installShellFiles,
  lib,
  stdenv,
  versionCheckHook,
  pkgs,
}:

let
  version = "unstable";
  appName = "aerospace-swipe";
in

stdenv.mkDerivation {
  pname = appName;
  inherit version;

  # Replace with actual git repo or local path
  src = fetchgit {
    url = "https://github.com/acsandmann/aerospace-swipe.git";
    rev = "master"; # pin to a commit hash or tag for stability
    sha256 = "0000000000000000000000000000000000000000000000000000000000000000"; # replace with actual hash
  };

  nativeBuildInputs = [ installShellFiles ];

  buildPhase = "make";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp aerospace-swipe $out/bin/

    runHook postInstall
  '';

  postInstall = ''
    # add man page or shell completion installation if available
    # e.g. installShellCompletion --bash shell-completion/bash/aerospace-swipe
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = builtins.toString (
    pkgs.writeScriptBin "update-aerospace-swipe" ''
      git clone https://github.com/acsandmann/aerospace-swipe.git tmp
      cd tmp
      echo "Current commit: $(git rev-parse HEAD)"
    ''
  );

  meta = {
    license = lib.licenses.mit;
    homepage = "https://github.com/acsandmann/aerospace-swipe";
    description = "Workspace switching with three-finger swipe on macOS using aerospace";
    platforms = lib.platforms.darwin;
    maintainers = [ ];
    sourceProvenance = [ lib.sourceTypes.nativeSource ];
  };
}
