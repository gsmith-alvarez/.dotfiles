function list_all_apps
    set -l output_file ~/Downloads/MasterList.md
    set -l timestamp (date "+%Y-%m-%d %H:%M:%S")

    # 1. Header and Metadata
    echo "# 🖥️ Master Software Inventory" >$output_file
    echo "Generated on: $timestamp" >>$output_file
    echo "Machine: Asus Zenbook S16 (Pop!_OS)" >>$output_file
    echo -e "---\n" >>$output_file

    # 2. Helper: Standard Code Block Section
    function _fmt_section
        set -l title $argv[1]
        set -l cmd $argv[2]
        set -l target_file $argv[3]
        echo "## 📦 $title" >>$target_file
        echo "```text" >>$target_file
        eval $cmd 2>/dev/null >>$target_file
        echo -e "```\n" >>$target_file
    end

    # 3. Helper: Markdown Table Section (Default 3 columns)
    function _fmt_table
        set -l title $argv[1]
        set -l cmd $argv[2]
        set -l target_file $argv[3]
        set -l cols 3 # Adjust this number for more or fewer columns

        echo "## 📦 $title" >>$target_file
        
        # Capture items into a list (Fish splits command substitution by newline)
        set -l items (eval $cmd 2>/dev/null)
        set -l total (count $items)
        
        if test $total -eq 0
            echo "_No items found._" >>$target_file
            echo -e "\n" >>$target_file
            return
        end

        # Create Table Header and Separator
        set -l header "|"
        set -l separator "|"
        for i in (seq $cols)
            set header "$header Column $i |"
            set separator "$separator --- |"
        end
        echo $header >>$target_file
        echo $separator >>$target_file

        # Chunk the list into rows
        set -l num_rows (math "ceil($total / $cols)")
        for i in (seq $num_rows)
            set -l start (math "($i - 1) * $cols + 1")
            set -l end (math "$i * $cols")
            set -l row_slice $items[$start..$end]
            
            # Ensure the row has exactly $cols items (pad with empty strings if needed)
            while test (count $row_slice) -lt $cols
                set row_slice $row_slice ""
            end
            
            echo "| "(string join " | " $row_slice)" |" >>$target_file
        end
        echo -e "\n" >>$target_file
    end

    # 4. Execution - Package Managers (Using Tables)
    _fmt_table "APT (Manual)" "apt-mark showmanual" $output_file
    _fmt_table "Homebrew" "brew list" $output_file
    _fmt_table "Flatpak" "flatpak list --app --columns=name,application" $output_file
    _fmt_table "Cargo" "cargo install --list | grep '^[a-z]'" $output_file

    # 5. Execution - Binary & AppImage Managers (Mixed Formats)
    _fmt_section "AM (AppImage Manager)" "am -f" $output_file # Keep as block (pre-formatted)

    if type -q bin
        _fmt_table "Bin Manager" "bin ls" $output_file
    end

    # 6. Execution - Local Filesystem (Using Tables)
    _fmt_table "Manual Binaries (~/.local/bin)" "eza -1 --icons=never ~/.local/bin" $output_file
    _fmt_table "User Scripts (~/scripts)" "eza -1 --icons=never ~/scripts" $output_file
    
    # 7. Execution - Chronological Intent (APT History)
    echo "## ⏳ Recent System Changes (Last 20 APT Commands)" >>$output_file
    echo "```bash" >>$output_file
    begin
        zcat (ls -tr /var/log/apt/history.log*.gz 2>/dev/null) 2>/dev/null
        cat /var/log/apt/history.log 2>/dev/null
    end | grep "Commandline:" | grep -v aptdaemon | tail -n 20 >>$output_file
    echo -e "```\n" >>$output_file

    # 8. Execution - Deep Analysis: True Manual Packages (Using Tables)
    # We capture the comm output first to simplify table processing
    _fmt_table "APT Metadata Analysis (Manual vs. Auto)" "comm -23 (dpkg-query -W -f='\${Package}\n' | sort | psub) (awk -v RS= '/Auto-Installed: *1/{print \$2}' /var/lib/apt/extended_states | sort | psub)" $output_file

    # 9. Final touch
    echo "✅ Master list generated at: $output_file"
    bat --paging=never $output_file
end