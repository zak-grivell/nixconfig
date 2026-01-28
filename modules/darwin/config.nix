{ ... }: {
  flake.modules.darwin.system = {
    security.pam.services.sudo_local.touchIdAuth = true;



  };
}
