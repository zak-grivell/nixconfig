{
  flake.modules.darwin.system = {
    homebrew.taps = [ "steipete/tap" ];
    homebrew.brews = [
      { name = "steipete/tap/remindctl"; trusted = true; }
    ];
  };

  flake.homeModules.default = { pkgs, ... }: {
    home.packages = with pkgs; [ cargo-clean-all lldb ];

    # Vendor installations are inventoried, not installed by this manifest.
    # Keep licensed installers and existing vendor update mechanisms intact.
    xdg.configFile."installed-software/manual.json".text = builtins.toJSON {
      matlab = {
        path = "/Applications/MATLAB_R2026b.app";
        installation = "MathWorks installer with a MATLAB licence";
      };
      rex-beta = {
        path = "/Applications/Rex Beta.app";
        installation = "Superlogical preview installer and built-in updater";
        feed = "https://blob.superlogical.com/public/rex-app/preview-arm64/appcast.xml";
      };
      cisco-secure-client = {
        path = "/opt/cisco/secureclient";
        installation = "Organisation-provided Cisco installer and VPN profiles";
      };
      python-framework = {
        path = "/Library/Frameworks/Python.framework";
        installation = "Existing python.org framework installation";
      };
      gstreamer-framework = {
        path = "/Library/Frameworks/GStreamer.framework";
        installation = "Existing vendor framework installation";
      };
      apple-command-line-tools = {
        path = "/Library/Developer/CommandLineTools";
        installation = "Apple Software Update";
      };
    };
  };
}
