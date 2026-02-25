# 🐟 Fish Functions Documentation

This directory contains custom fish functions designed to enhance the terminal experience with fuzzy finding, better search, and improved workflows.

## 🚀 Quick Reference

| Command | Description |
| :--- | :--- |
| `bmo` | Fuzzy find and open Bookmarks (requires `bmm`). |
| `fkill` | Fuzzy find and kill processes with multi-select support. |
| `j` | Smart directory jumper (zoxide). Opens fzf if no argument is provided. |
| `list_all_apps` | Generates a comprehensive software inventory in `~/Downloads/MasterList.md`. |
| `man` | Enhanced `man` pages with syntax highlighting via `bat`. |
| `nfzf` | Fuzzy find files and open them in your `$EDITOR`. |
| `rga-fzf` | Search inside PDFs, Office Docs, etc., and open them. |
| `sg` | Fuzzy search file contents and open in Neovim at the exact line. |
| `wtf` | Uses `aider` to diagnose and suggest fixes for recent command failures. |
| `y` | `yazi` wrapper that syncs your shell's CWD with yazi's exit directory. |
| `zk` | Fuzzy session manager for Zellij (create or attach). |

---

## 🛠️ Detailed Function Overviews

### `bmo`
Uses `bmm` to list bookmarks, pipes them to `fzf` for selection, and opens the URI using `xdg-open`.

### `fkill`
**Description:** Fuzzy kill processes.
**Usage:** `fkill`
- Use `TAB` to multi-select processes.
- Use `ENTER` to kill the selected PID(s) with `kill -9`.

### `j`
**Description:** Enhanced directory jumping.
**Usage:** `j [path]`
- If a path is provided, it acts as a shortcut for `z [path]`.
- If no path is provided, it opens a fuzzy list of your `zoxide` history with a directory tree preview (`eza`).

### `list_all_apps`
**Description:** Generates a `MasterList.md` file in your Downloads folder containing all installed software across APT, Flatpak, Homebrew, Cargo, and local binaries.

### `man`
**Description:** Wraps the standard `man` command to use `bat` as the pager, providing syntax highlighting and a better reading experience.

### `nfzf`
**Description:** Finds files (hidden files included, `.git` excluded) using `fd` and opens the selection in your default `$EDITOR`.

### `rga-fzf`
**Description:** Uses `ripgrep-all` (rga) to search through "unstructured" data like PDFs and Ebooks. Opens the selected file in the background.

### `sg`
**Description:** A powerful content searcher. Uses `ripgrep` for searching and `fzf` for selection. It provides a live preview of the match and opens Neovim at the specific line number when selected.

### `wtf`
**Description:** When a command fails, run `wtf`. it grabs the last 5 commands from `atuin` and sends them to `aider` to explain why they failed and how to fix them.

### `y`
**Description:** The standard `yazi` shell wrapper. It ensures that when you quit `yazi`, your shell remains in the last directory you navigated to.

### `zk`
**Description:** Quickly attach to an existing Zellij session or create a new one based on the current directory name using `fzf`.
