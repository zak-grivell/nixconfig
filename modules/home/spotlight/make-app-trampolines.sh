# Credit: https://github.com/nix-community/home-manager/issues/1341#issuecomment-1705731962
# That author wrote https://github.com/hraban/mac-app-util.
# Someone then rewrote that in bash, which I understand more than lisp:
# https://github.com/nix-community/home-manager/issues/1341#issuecomment-1870352014
# I have adapted parts of this for some reason, mostly to ensure I understand
# it, but might switch to one of these solutions one day.

fromDir="$HOME/Applications/Home Manager Apps"
toDir="$HOME/Applications/Home Manager Trampolines"
mkdir -p "$toDir"

(
  cd "$fromDir"
  for app in *.app; do
    /usr/bin/osacompile -o "/tmp/$app" -e "do shell script \"open '$fromDir/$app'\""

    chown -R "$USER":staff "/tmp/$app"

    rm -f "/tmp/$app/Contents/Resources/appicon.icns"

    # Just clobber the applet icon laid down by osacompile rather than do
    # surgery on the plist.
    cp "$fromDir/$app/Contents/Resources"/*.icns "/tmp/$app/Contents/Resources/appicon.icns"

    mv "/tmp/$app" "$toDir/$app"
  done
)

# cleanup
(
  cd "$toDir"
  for app in *.app; do
    if [ ! -d "$fromDir/$app" ]; then
      rm -rf "$toDir/$app"
    fi
  done
)
