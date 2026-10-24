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
  ];

  programs.fish.enable = true;

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    historyWidget.fish.command = "";
    historyWidget.bash.command = "";
  };

  programs.mcfly = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    nix-direnv.enable = true; # Highly recommended for Nix users to speed up environment loading
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.home-manager.enable = true;

  xdg.enable = true;
}
