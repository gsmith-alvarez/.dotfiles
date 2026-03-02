function sg -d "Fuzzy search file contents and open in Neovim"
    # 1. Search with rg, pipe to fzf with a bat preview centered on the match
    set -l match (rg --color=always --line-number --no-heading --smart-case "" | \
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')

    # 2. Extract file and line number, then open in editor
    if test -n "$match"
        set -l file (string split -m 2 ":" "$match")[1]
        set -l line (string split -m 2 ":" "$match")[2]
        $EDITOR "+$line" "$file"
    end
end
