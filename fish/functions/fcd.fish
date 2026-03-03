function fcd --description "Fuzzy search current directory and jump"
    # 1. Use fd to find directories (ignoring .git and hidden folders)
    # 2. Pipe to fzf for selection
    set -l result (fd --type d --hidden --exclude .git . | fzf --height=40% --layout=reverse)

    # If we picked something (didn't hit ESC)
    if test -n "$result"
        cd "$result"
        # Refresh the prompt so you see the new path
        commandline -f repaint
    end
end
