{ pkgs, lib, ... }:
let
  mod = "Mod4";
in
{
  home.username = "shidou";
  home.homeDirectory = "/home/shidou";
  home.packages = [ pkgs.xfce.thunar pkgs.devenv];
  home.sessionVariables.EDITOR = "nvim";

  programs.bash = {
    enable = true;
    bashrcExtra = '' 
    eval "$(direnv hook bash)"
    ''; };

  programs.git = {
    enable = true;
    userEmail = "jvrmalv@gmail.com";
    userName = "Joao Vitor";
  };

  programs.neovim = {
    plugins = [
    {
    plugin = pkgs.vimPlugins.nvim-treesitter;
    }
    pkgs.vimPlugins.nvim-treesitter-parsers.nix
    pkgs.vimPlugins.nvim-treesitter-parsers.bash
    pkgs.vimPlugins.nvim-treesitter-parsers.json
    pkgs.vimPlugins.nvim-treesitter-parsers.vim
    pkgs.vimPlugins.nvim-treesitter-parsers.lua
    ];
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      filetype plugin indent on
      set autoindent
      set tabstop=2
      set softtabstop=2
      set shiftwidth=2
      set expandtab
      set number
    '';
  };

  programs.alacritty = {
    enable = true;
  };

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;

      fonts = [ "DejaVu Sans Mono, FontAwesome 6" ];
      defaultWorkspace = "workspace number 1";

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

	      # Split Conatainer
	      "${mod}+Shift+g" = "split horizontal";
	      "${mod}+Shift+v" = "split vertical";

        # My multi monitor setup
        # "${mod}+m" = "move workspace to output {MONITOR NAME}";
        # "${mod}+Shift+m" = "move workspace to output {MONITOR NAME}"; };
      };
      modes = lib.mkOptionDefault {
        resize = {
          j= "resize grow height 10 px or 10 ppt"; Escape = "mode default";
          h= "resize shrink width 10 px or 10 ppt";
          Esc= "mode default";
          l= "resize grow width 10 px or 10 ppt";
          k= "resize shrink height 10 px or 10 ppt";
          };
        };
      };
    };

  programs.direnv = {
    enable = true; enableBashIntegration = true; nix-direnv.enable = true; 
  }; 

  home.stateVersion = "23.05";
}


