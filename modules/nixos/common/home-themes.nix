{ pkgs, config, ... } :

let
swift-notification-listener = pkgs.stdenv.mkDerivation {
  pname = "notification-listener";
  version = "0.1.0";

  # The Swift source code
  src = pkgs.writeText "notification_listener.swift" ''
    import Foundation

    let filePath = "/Users/zakgrivell/.local/state/nix/profiles/home-manager/specialisation"

    // Read the real path of the home-manager specialisation symlink
    // This ensures we're always pointing to the active generation
    let fileContents = try! String(contentsOfFile: filePath, encoding: .utf8)
    let path = fileContents.trimmingCharacters(in: .whitespacesAndNewlines)

    // Helper to get current appearance
    func currentAppearance() -> String {
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        return type == "Dark" ? "Dark" : "Light"
    }

    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh" // Or /bin/bash, ensure it's available
        task.standardInput = nil
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }

    func switch_theme() {
        let mode = currentAppearance()
        print("Appearance changed: \(mode)")

        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe

        // Construct the full path to the activate scripts based on the resolved home-manager path
        if mode == "Dark" {
            process.executableURL = URL(fileURLWithPath: path + "/dark/activate")
        } else if mode == "Light" {
            process.executableURL = URL(fileURLWithPath: path + "/light/activate")
        }

        // Ensure the executableURL is valid before trying to run
        if let url = process.executableURL {
            print("Attempting to run: \(url.path)")
            do {
                try process.run()
                process.waitUntilExit()
                print("Script exited with status: \(process.terminationStatus)")
            } catch {
                print("Error running script: \(error)")
            }
        } else {
            print("Executable URL not set for mode: \(mode)")
        }

        shell("pkill -USR1 hx") // Ensure hx is in launchd's PATH if this needs to work
    }

    print("Nix Home Manager Path: \(path)")
    switch_theme()

    // Listen for theme changes
    let center = DistributedNotificationCenter.default()
    let notificationName = Notification.Name("AppleInterfaceThemeChangedNotification")

    center.addObserver(
        forName: notificationName,
        object: nil,
        queue: .main
    ) { _ in
        switch_theme()
    }

    // Keep the script running
    RunLoop.main.run()
  '';
  # Build steps
  nativeBuildInputs = [ pkgs.swift ]; # Ensure Swift compiler is available
  buildPhase = ''
    swiftc "$src" -o "$out/bin/notification_listener"
  '';
};
in {
    # Create a derivation for the Swift notification listener
    # This will compile the Swift code into the Nix store




    # Make the Swift program available as a system package (optional, but good practice)
    environment.systemPackages = [
      swift-notification-listener # Refer to the derivation defined above
    ];

    # Create a LaunchAgent to run the notification listener
    launchd.user.agents.notification-handler = {
      serviceConfig = {
        # Refer to the output path of the Nix derivation
        ProgramArguments = ["${swift-notification-listener}/bin/notification_listener"];
        RunAtLoad = true;
        KeepAlive = true;
        StandardErrorPath = "/tmp/notification-listener.err";
        StandardOutPath = "/tmp/notification-listener.out";
      };
    };
}
