{
  flake.homeModules.default = { pkgs, ... }:
  {
    home.packages = with pkgs; [
      karabiner-elements
    ];

    xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
      global = {
        ask_for_confirmation_before_quitting = false;
        show_in_menu_bar = false;
      };

      profiles = [
        {
          name = "Default profile";
          selected = true;

          virtual_hid_keyboard = {
            keyboard_type_v2 = "ansi";
          };

          simple_modifications = [
            {
              from.key_code = "caps_lock";
              to = [ { key_code = "escape"; } ];
            }
          ];
        }
      ];
    };
  };
}
