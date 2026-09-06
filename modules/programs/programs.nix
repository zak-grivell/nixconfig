{
  flake.homeModules.default = { pkgs, ... }: {
    programs = {
      zoxide = { enable = true; enableNushellIntegration = true;};
      ripgrep.enable = true;
      fd.enable = true;
      bat.enable = true;
      atuin = {
        enable = true;
        enableNushellIntegration = true;
        flags = [ "--disable-up-arrow" ];
      };
      
    };

    
    home.packages = with pkgs; [
      tree

        nixd # Nix LSP with flake support
        alejandra # Opinionated Nix formatter
    ];
  };
}
