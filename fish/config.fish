status is-interactive; or exit 0

fzf --fish | source
bind \cr fzf-history-widget
bind -M insert \cr fzf-history-widget

zoxide init fish --cmd z | source

alias ls 'eza --group-directories-first --icons'
alias ll 'eza -l --group-directories-first --icons --git'
alias la 'eza -la --group-directories-first --icons --git'
alias lt 'eza --tree --level=2 --icons'
alias top 'btop'
