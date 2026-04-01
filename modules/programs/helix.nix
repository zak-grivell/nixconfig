{
  flake.homeModules.default = {lib, pkgs, ...}: let
    helixBundle = pkgs.runCommand "HelixOpen" {} ''
      mkdir -p $out/Applications/HelixOpen.app/Contents/MacOS

      cat > $out/Applications/HelixOpen.app/Contents/MacOS/HelixOpen <<EOF
      #!/bin/bash
      open -a Ghostty --args ${pkgs.helix}/bin/hx "$1"
      EOF
      chmod +x $out/Applications/HelixOpen.app/Contents/MacOS/HelixOpen

      cat > $out/Applications/HelixOpen.app/Contents/Info.plist <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key><string>HelixOpen</string>
        <key>CFBundleIdentifier</key><string>com.helix.open</string>
        <key>CFBundleName</key><string>HelixOpen</string>
        <key>CFBundleVersion</key><string>1.0</string>
        <key>CFBundleDocumentTypes</key>
        <array>
          <dict>
            <key>CFBundleTypeRole</key><string>Editor</string>
            <key>LSItemContentTypes</key>
            <array>
              <string>public.plain-text</string>
              <string>public.source-code</string>
            </array>
          </dict>
        </array>
      </dict>
      </plist>
      EOF
    '';
  in {
    home.packages = [pkgs.duti helixBundle];

    home.activation.setHelixDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Let LaunchServices discover the new app bundle
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
          -f ~/.nix-profile/Applications/HelixOpen.app

        # Set as default for common text types
        $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.helix.open public.plain-text all
        $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.helix.open public.source-code all
        $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.helix.open .md all
        $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.helix.open .txt all
        $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s com.helix.open .typ all
      '';

    programs = {
      helix = {
        enable = true;
        # package = inputs.helix-cargo.packages.aarch64-darwin.default;
        defaultEditor = true;

        settings = {
          theme = lib.mkForce "catppuccin_frappe";
          editor = {
            cursor-shape.insert = "bar";
            inline-diagnostics.cursor-line = "hint";
            auto-save = {
              focus-lost = true;
              after-delay.enable = true;
            };
            soft-wrap.enable = true;
            line-number = "relative";
            end-of-line-diagnostics = "hint";
            bufferline = "always";
          };
          keys.normal = {
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
            space.f = "file_picker_in_current_directory";
            space.F = "file_picker";
          };
        };
        languages = {
          language-server.rust-analyzer.config.check.command = "clippy";
          language = [
            {
              name = "nix";
              formatter = {
                command = "alejandra";
              };
            }
          ];
        };
      };
    };
  };
}
