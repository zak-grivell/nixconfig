{ ... }:
{
  home.file = {
    ".confg/aerospace/move-from-temp.bash".text = ''
      # Get the workspace of the currently focused window
      current_workspace=$(aerospace list-windows --focused --format '%{workspace}')

      # Get the window ID of the currently focused window
      focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')

      # If the current workspace is "temp", move the focused window to its workspace
      if [ "$current_workspace" = "temp" ]; then
        aerospace move-node-to-workspace "$focused_window_id" --focus-follows-window
      fi
    '';

    ".config/aerospace/relocate.bash".text = ''
      n="$1"

      workspace="$(aerospace list-workspaces --monitor focused | sed "$nq;d")"

      # If no workspace at that index, define a fallback name and let move create it
      if [ -z "$workspace" ]; then
          workspace=$(aerospace list-windows --focused --format '%{window-id}')
      fi

      # Move focused window to target workspace, focus follows
      aerospace move-node-to-workspace $workspace --focus-follows-window
    '';

    ".config/aerospace/send.bash".text = ''
      n="$1"

      workspace="$(aerospace list-workspaces --monitor focused | sed "$nq;d")"

      # If no workspace at that index, define a fallback name and let move create it
      if [ -z "$workspace" ]; then
          workspace=$(aerospace list-windows --focused --format '%{window-id}')
      fi

      # Move focused window to target workspace, focus follows
      aerospace move-node-to-workspace $workspace
    '';

    ".config/aerospace/workspace.bash'.text" = ''
      n="$1"

      workspace="$(aerospace list-workspaces --monitor focused | sed "$nq;d")"

      # If no workspace at that index, define a fallback name and let move create it
      if [ -z "$workspace" ]; then
          workspace=$(aerospace list-windows --focused --format '%{window-id}')
      fi

      # Move focused window to target workspace, focus follows
      aerospace workspace $workspace
    '';
  };

}
