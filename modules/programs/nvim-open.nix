{
  flake.homeModules.default = {
    config,
    lib,
    pkgs,
    ...
  }: let
    applet = pkgs.writeText "NvimOpen.applescript" ''
      on run
        launchNvim({})
      end run

      on open fileList
        launchNvim(fileList)
      end open

      on launchNvim(fileList)
        set commandLine to quoted form of "${config.programs.nixvim.build.package}/bin/nvim"
        repeat with selectedFile in fileList
          set commandLine to commandLine & " " & quoted form of POSIX path of selectedFile
        end repeat
        tell application "Terminal"
          activate
          do script commandLine
        end tell
      end launchNvim
    '';
  in {
    home.activation.nvimOpen = lib.hm.dag.entryAfter ["writeBoundary"] ''
      app="$HOME/Applications/NvimOpen.app"
      temporary=$(/usr/bin/mktemp -d)
      /usr/bin/osacompile -o "$temporary/NvimOpen.app" ${applet}
      # Keep the bundle identifier so existing Finder associations follow the launcher.
      /usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string com.helix.open' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Delete :CFBundleDocumentTypes' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes array' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0 dict' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:LSItemContentTypes array' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:LSItemContentTypes:0 string public.plain-text' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/libexec/PlistBuddy -c 'Add :CFBundleDocumentTypes:0:LSItemContentTypes:1 string public.source-code' "$temporary/NvimOpen.app/Contents/Info.plist"
      /usr/bin/codesign --force --sign - "$temporary/NvimOpen.app"
      /bin/mkdir -p "$HOME/Applications"
      if [ -e "$app" ]; then
        /bin/chmod -R u+w "$app"
        /bin/mv "$app" "$temporary/previous.app"
      fi
      /bin/mv "$temporary/NvimOpen.app" "$app"
      lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
      legacy="$HOME/Applications/HelixOpen.app"
      if [ "$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$legacy/Contents/Info.plist" 2>/dev/null)" = com.helix.open ]; then
        "$lsregister" -u "$legacy" || true
        /bin/chmod -R u+w "$legacy"
        /bin/mv "$legacy" "$temporary/legacy.app"
      fi
      "$lsregister" -f "$app"
      /bin/rm -rf "$temporary"
    '';
  };
}
