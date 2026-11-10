{
  flake.homeModules.default = {
    config,
    lib,
    pkgs,
    ...
  }: let
    launcher = pkgs.writeShellScript "helix-open" ''
      for app in /Applications/Rex.app "/Applications/Rex Beta.app"; do
        rex="$app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
        if [ -x "$rex" ]; then
          /usr/bin/open -a "$app"
          exec "$rex" run --shell=none --label Helix -- ${config.programs.helix.package}/bin/hx "$@"
        fi
      done
      echo "HelixOpen requires Rex in /Applications" >&2
      exit 1
    '';
    applet = pkgs.writeText "HelixOpen.applescript" ''
      on run
        launchHelix({})
      end run

      on open fileList
        launchHelix(fileList)
      end open

      on launchHelix(fileList)
        set commandLine to quoted form of "${launcher}"
        repeat with selectedFile in fileList
          set commandLine to commandLine & " " & quoted form of POSIX path of selectedFile
        end repeat
        do shell script commandLine
      end launchHelix
    '';
  in {
    home.activation.helixOpen = lib.hm.dag.entryAfter ["writeBoundary"] ''
      app="$HOME/Applications/HelixOpen.app"
      temporary=$(/usr/bin/mktemp -d)
      /usr/bin/osacompile -o "$temporary/HelixOpen.app" ${applet}
      /usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string com.helix.open' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Delete :CFBundleDocumentTypes' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes array' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0 dict' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:LSItemContentTypes array' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:LSItemContentTypes:0 string public.plain-text' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:LSItemContentTypes:1 string public.source-code' "$temporary/HelixOpen.app/Contents/Info.plist"
      /usr/bin/codesign --force --sign - "$temporary/HelixOpen.app"
      /bin/mkdir -p "$HOME/Applications"
      if [ -e "$app" ]; then
        /bin/chmod -R u+w "$app"
        /bin/mv "$app" "$temporary/previous.app"
      fi
      /bin/mv "$temporary/HelixOpen.app" "$app"
      /bin/rm -rf "$temporary"
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
    '';
  };
}
