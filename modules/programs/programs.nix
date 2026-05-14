{
  flake.homeModules.default = { pkgs, ... }: {
    programs = {
      fzf.enable = true;
      zoxide = { enable = true; enableNushellIntegration = true;};
      ripgrep.enable = true;
      fd.enable = true;
      bat.enable = true;
      atuin = {
        enable = true;
        enableNushellIntegration = true;
      };
      
    };

    
    home.packages = with pkgs; [
      tree

        nixd # Nix LSP with flake support
        alejandra # Opinionated Nix formatter
    ];
  };
}
