{ config, pkgs, ... }:

{
  home.username = "chander";
  home.homeDirectory = "/home/chander";

  home.stateVersion = "26.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.lolcat
    pkgs.rclone
    pkgs.megacmd
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

  programs.home-manager.enable = true;

  xdg.enable = true;
}
