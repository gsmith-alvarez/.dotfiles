function nfzf
    set -l files (fd --type f --hidden --exclude .git | fzf -m --preview="bat --color=always {}")
    if test (count $files) -gt 0
        $EDITOR $files
    end
end
