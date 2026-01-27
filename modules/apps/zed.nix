{ ... }: {
   flake.modules.homeManager.zakbook = { pkgs, ...}: {
     programs.fish.shellAliases.zed = "zeditor";

     programs.zed-editor = {
       enable = true;

       extensions = [
         "html"
         "catppucin"
         "toml"
         "java"
         "catppuccin"
         "catppuccin_icons"
         "nix"
         "lua"
       ];

       extraPackages = [ pkgs.nixd ];

       userSettings = {
         icon_theme = {
           light = "Catppuccin Latte";
           dark = "Catppuccin Frappé";
           mode = "system";
         };
         theme = {
           light = "Catppuccin Latte";
           dark = "Catppuccin Frappé";
           mode = "system";
         };
         features = {
           edit_prediction_provider = "zed";
         };

         which_key = {
           enabled = true;
           delay_ms = 100;
         };

         helix_mode = true;
         ui_font_size = 14;
         buffer_font_size = 14;

         diagnostics.inline.enabled = true;
         terminal.toolbar.breadcrumbs = false;

         autosave = "on_focus_change";

         debugger.dock = "right";
         # inline_code_actions = false;
         scrollbar.show = "never";
         terminal.dock = "right";

         languages = {
           Python = {
             language_servers = [
               "ty"
               "!basedpyright"
               "..."
             ];
           };

           Java = {
             "format_on_save" = "off";
           };
         };
       };

       userKeymaps = [
         {
           context = "Workspace && Editor";
           bindings = {
             ctrl-a = "workspace::ToggleLeftDock";
             ctrl-s = "workspace::ToggleBottomDock";
             ctrl-d = "workspace::ToggleRightDock";
             ctrl-o = "projects::OpenRecent";
           };
         }
         {
           context = "(VimControl && !menu)";
           bindings = {
             space = null;
           };
         }
         {
           context = "Editor";
           bindings = {
             alt-tab = "editor::AcceptEditPrediction";
           };
         }
         {
           "context" = "Editor && inline_completion";
           "bindings" = {
             "tab" = null;
           };
         }
       ];
     };
   };
}
