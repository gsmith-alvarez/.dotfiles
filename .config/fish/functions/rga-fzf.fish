function rga-fzf -d "Search inside PDFs and Office Docs"
    set -l query (commandline -j)
    
    # Use rga to search files, pass to fzf, preview matches with rga's context output
    set -l file (rga --rga-adapters=poppler,pandoc,tesseract --files-with-matches "" | \
        fzf --preview="rga --pretty --context 5 '' {}" \
            --preview-window="right:60%:wrap")

    if test -n "$file"
        xdg-open "$file" >/dev/null 2>&1 &
        disown
    end
end
