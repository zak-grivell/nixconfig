#!/bin/bash

# Swift script to listen for NSNotifications
cat > /tmp/notification_listener.swift << 'EOF'
// filename: listen_theme_change.swift

import Foundation

// Helper to get current appearance
func currentAppearance() -> String {
    let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
    return type == "Dark" ? "Dark" : "Light"
}

func resolveSymlink(_ path: String) -> String? {
    // Get the absolute path first
    let absolutePath = (path as NSString).expandingTildeInPath

    // Use realpath(3) for canonicalization
    if let resolved = absolutePath.withCString({ realpath($0, nil) }) {
        let result = String(cString: resolved)
        free(resolved)
        return result
    } else {
        // realpath returns nil if the file doesn't exist or can't be resolved
        return nil
    }
}

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}


let path = resolveSymlink("/Users/zakgrivell/.local/state/nix/profiles/home-manager/specialisation")!

func switch_theme() {
    let mode = currentAppearance()
    print("Appearance changed: \(mode)")

    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe

    if mode == "Dark" {
        process.executableURL = URL(fileURLWithPath: path + "/dark/activate")
    } else if mode == "Light" {
        process.executableURL = URL(fileURLWithPath: path + "/light/activate")
    }

    // helix reload
    try! process.run()

    process.waitUntilExit()


    shell("pkill -USR1 hx")

}

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

EOF

# Compile and run the Swift script
swiftc -o /tmp/notification_listener /tmp/notification_listener.swift
/tmp/notification_listener
