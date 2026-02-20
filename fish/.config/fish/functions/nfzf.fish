function nfzf
    set -l file (fzf --preview="bat --color=always {}")
    if test -n "$file" #if there is no file it doesn't open
        $EDITOR $file
    end
end
