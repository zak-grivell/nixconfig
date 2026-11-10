{
  flake.homeModules.default = { pkgs, ... }: {
    programs = {
      zoxide = { enable = true; enableFishIntegration = true;};
      ripgrep.enable = true;
      fd.enable = true;
      bat.enable = true;
      # atuin = {
      #   enable = true;
      #   enableFishIntegration = true;
      #   flags = [ "--disable-up-arrow" ];
      # };
      
    };

    
    home.packages = with pkgs; [
      tree
      heroku
      nixd # Nix LSP with flake support
      alejandra # Opinionated Nix formatter
    ];
  };
}
