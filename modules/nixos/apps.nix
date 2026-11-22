{
  flake.homeModules.linux = {pkgs, ...}: {
    home.packages = with pkgs; [
      chatgpt
      discord
      dotnet-sdk
      godot-mono
      karere
      kicad
      orca-slicer
      prismlauncher
      proton-vpn
      t3code
      zoom-us
      (callPackage ../../packages/helium-browser {})
      (callPackage ../../packages/mole-linux {})
    ];

    xdg.desktopEntries.icloud-reminders = {
      name = "iCloud Reminders";
      exec = "zen-beta https://www.icloud.com/reminders/";
      categories = ["Office"];
    };
  };
}
