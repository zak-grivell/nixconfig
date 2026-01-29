{
   flake.homeModules.disabled = { pkgs, lib, ...}: let
     appName = "KiCAD.app";
     version = "9.0.7";

     kicad-dmg = pkgs.stdenv.mkDerivation {
       pname = "kicad";
       inherit version;

       src = pkgs.fetchzip {
         url = "https://github.com/KiCad/kicad-source-mirror/releases/download/${version}/kicad-unified-universal-${version}.dmg";
         sha256 = "sha256:449525e4ac119dc79a36b9a5aba5e6a269ecdc1905b94dce9eaf44ea45fd84c2";
       };

       nativeBuildInputs = [
         pkgs.undmg
       ];

       installPhase = ''
         mkdir -p $out/Applications
         cp -R ${appName} $out/Applications/
       '';

       meta = {
         description = "A Cross Platform and Open Source PCB Design Suite";
         homepage = "https://www.kicad.org/";
         license = lib.licenses.gpl3Plus;
         platforms = lib.platforms.darwin;
       };
     };
   in {
     home.packages = with pkgs; [
       kicad-dmg
    ];
  };
}
# look into base code
# resarch lora - remind to get resorces
#
