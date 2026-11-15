{ config, pkgs, ... }:

{
  xdg.enable = true;
  nix.assumeXdg = true;
  nixpkgs.config.allowUnfree = true;

  home.username = "chander";
  home.homeDirectory = "/home/chander";
  home.stateVersion = "26.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.stow
    pkgs.vim
    pkgs.eza
    pkgs.bat
    pkgs.lolcat
    pkgs.htop
    pkgs.jq
    pkgs.rclone
    pkgs.gh
  ];

  programs.home-manager.enable = true;
  programs.fish.enable = true;

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    historyWidget.fish.command = "";
  };

  programs.mcfly = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
