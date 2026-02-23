function bmo
    # 1. Get the URI using the pipeline
    set -l target (bmm list --format json | jq -r '.[] | .uri + " " + .title' | fzf | awk '{print $1}')

    # 2. If a target was selected (not empty)
    if test -n "$target"
        # 3. Launch xdg-open, silence all output, and run in background
        xdg-open "$target" >/dev/null 2>&1 &

        # 4. Detach it from the current shell session
        disown
    end
end
