status is-interactive; or exit 0

fzf --fish | source
bind \cr fzf-history-widget
bind -M insert \cr fzf-history-widget

zoxide init fish --cmd z | source

abbr -a ls 'eza --group-directories-first --icons'
abbr -a ll 'eza -l --group-directories-first --icons --git'
abbr -a la 'eza -la --group-directories-first --icons --git'
abbr -a lt 'eza --tree --level=2 --icons'
abbr -a top btop
