{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "chander";
  home.homeDirectory = "/home/chander";

  home.stateVersion = "26.05"; # Please read the comment before changing.

  home.packages = [
   pkgs.eza
   pkgs.fish
   pkgs.bat
   pkgs.zoxide
   pkgs.direnv
   pkgs.btop
   pkgs.age
   pkgs.yazi
   pkgs.fzf
   pkgs.sops
   pkgs.procs
   pkgs.mcfly
   pkgs.gh
   pkgs.stow
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg.enable = true;
}
