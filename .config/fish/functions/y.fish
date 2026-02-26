function y --description "Yazi wrapper: Zoxide state sync + Neovim handoff"
    # Create isolated temp files for both directory state and file selection
    set tmp_cwd (mktemp -t "yazi-cwd.XXXXXX")
    set tmp_file (mktemp -t "yazi-file.XXXXXX")

    # Execute Yazi, capturing both the final directory and the selected file
    yazi $argv --cwd-file="$tmp_cwd" --chooser-file="$tmp_file"

    # 1. State Sync: Update directory and feed the Zoxide database
    if set cwd (command cat -- "$tmp_cwd"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        z "$cwd"
    end

    # 2. Handoff: If you hit <Enter> on a file, open it in Neovim natively
    if set chosen (command cat -- "$tmp_file"); and test -n "$chosen"
        nvim "$chosen"
    end

    # 3. Memory Management: Ruthless cleanup
    rm -f -- "$tmp_cwd" "$tmp_file"
end
