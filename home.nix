{ pkgs, lib, ... }:
let
  mod = "Mod4";
in
{
  home.username = "shidou";
  home.homeDirectory = "/home/shidou";
  home.packages = [ pkgs.xfce.thunar];
  home.sessionVariables.EDITOR = "nvim";

  programs.bash.enable = true;

  programs.git = {
    enable = true;
    userEmail = "jvrmalv@gmail.com";
    userName = "Joao Vitor";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.alacritty = {
    enable = true;
  };

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;

      fonts = [ "DejaVu Sans Mono, FontAwesome 6" ];

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${mod}+p" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";

        # Focus
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # Move
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";


        # My multi monitor setup
        # "${mod}+m" = "move workspace to output {MONITOR NAME}";
        # "${mod}+Shift+m" = "move workspace to output {MONITOR NAME}"; };
      };
    };
  };
  home.stateVersion = "23.05";
}

