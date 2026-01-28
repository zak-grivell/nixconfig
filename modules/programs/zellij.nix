{
  flake.homeModules.default = {
    programs.zellij = {
      enable = true;
      settings = {
        theme = "catppuccin-frappe";
      };
    };
  };
}
