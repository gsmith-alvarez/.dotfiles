function j
    if test (count $argv) -eq 0
        # Get current dir and strip any trailing slash for a clean match
        set -l current_dir (pwd | string replace -r '/$' '')
        # Use a regex anchor to ensure we match exactly the path or the path with a slash
        set -l escaped_dir (string escape --style=regex "$current_dir")
        set -l drive (zoxide query -l | string match -v -r "^$escaped_dir/?\$" | fzf --height 40% --layout=reverse --border --preview 'eza -T -L 1 --icons --color=always {1}')

        if test -n "$drive"
            z "$drive"
        end
    else
        z $argv
    end

end
