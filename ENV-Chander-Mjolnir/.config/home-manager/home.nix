{ config, pkgs, ... }:

{
  home.username = "chander";
  home.homeDirectory = "/home/chander";

  home.stateVersion = "26.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.stow
    pkgs.eza
    pkgs.procs
    pkgs.bat
    pkgs.lolcat
    pkgs.rclone
    pkgs.btop
    pkgs.jq
    pkgs.age
    pkgs.sops
  ];

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

  programs.home-manager.enable = true;

  xdg.enable = true;
}
