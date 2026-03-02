# 🛠️ System Keybinds & Shortcuts Reference

This document provides a consolidated view of the keyboard shortcuts, shell abbreviations, and automation logic configured across this dotfiles ecosystem.

---

## 🚨 Potential Conflicts
*   **Navigation (`C-h/j/k/l`)**: Shared between **VSCodium**, **Zellij**, and **FZF**. Conflicts will occur if VSCodium is nested in Zellij without `smart-splits` handling, or during modal FZF sessions.
*   **Leader Keys**: `Space` is the primary leader for both **VSCodium (vscode-neovim)** and **Neovim** — `lua/core/vscode.lua` maps them to the same VSCode commands so the surface is identical.
*   **Zellij Alt-Prefix**: Zellij uses `Alt` for almost all multiplexer controls, which may shadow terminal application shortcuts (e.g., `Alt+b`/`Alt+f` for word movement).

---

## 🌍 Ecosystem Overview
*   **Code**: VSCodium configured via `vscode-neovim` — same `<leader>` keymap surface as Neovim (`lua/core/vscode.lua`).
*   **Atuin**: SQLite-backed global shell history sync.
*   **COSMIC**: System76's desktop environment (Tiling & Workspaces).
*   **Fish**: Primary shell with Vi-mode and "Modern Unix" tool integration.
*   **Ghostty**: High-performance terminal emulator.
*   **Mise**: Polyglot tool manager for runtimes and CLI utilities.
*   **Zellij**: Terminal multiplexer and workspace integrator.

---

## 📂 Navigation & File Management

| Key/Command | Context | Action |
| :--- | :--- | :--- |
| `j [path]` | Fish | Smart jumper (Zoxide); opens FZF list if no path provided. |
| `nfzf` | Fish | Fuzzy find files via `fd` and open in `$EDITOR`. |
| `y` | Fish | Yazi wrapper: Syncs directory on exit; opens files in Neovim on Enter. |
| `yr` | Fish (Abbr) | Shortcut for `yazi`. |
| `..` / `...` | Fish (Abbr) | Ascend 1 or 2 directory levels. |
| `ctrl+h/l` | VSCodium | Pane navigation (left/right editor group). |
| `Alt [ / ]` | Zellij | Navigate to Previous/Next Tab. |

---

## 🔍 Search & Diagnostics (LSP)

| Key/Command | Context | Action |
| :--- | :--- | :--- |
| `sg` | Fish | Search file contents (`rg`) and open Neovim at exact line. |
| `nvq` | Fish | Send `ripgrep` results directly to Neovim Quickfix list. |
| `wtf` | Fish | Use AI (`aider`) to diagnose the last 5 command failures. |
| `rga-fzf` | Fish | Search inside PDFs, Docs, etc. (`ripgrep-all`). |
| `ctrl+j/k` | VSCodium | Navigate suggestions, code actions, or parameter hints. |
| `ctrl+l` | VSCodium | Accept suggestion or code action. |

---

## 🌿 Git Operations

| Key/Command | Context | Action |
| :--- | :--- | :--- |
| `lg` | Fish (Abbr) | Launch `lazygit`. |
| `gs` / `ga` | Fish (Abbr) | `git status` / `git add`. |
| `gc` / `gp` | Fish (Abbr) | `git commit -m` / `git push`. |
| `<leader>gg` | Neovim / VSCodium | Open lazygit (snacks terminal / integrated terminal). |
| `]h` / `[h` | Neovim / VSCodium | Next / Previous git hunk. |
| `<leader>hs` / `hr` | Neovim / VSCodium | Stage / Reset hunk. |

---

## 🪟 UI & Window Management

| Key/Command | Context | Action |
| :--- | :--- | :--- |
| `super+return`| Cosmic | Launch Terminal (Ghostty). |
| `super+shift+s`| Cosmic | System Screenshot. |
| `super+n` | Cosmic | Minimize current window. |
| `Alt+equal/-` | Cosmic | Next/Previous Workspace. |
| `Alt n / N` | Zellij | Create new Pane / New Tab. |
| `Alt x / X` | Zellij | Close current Pane / Current Tab. |
| `Alt f / w / z`| Zellij | Toggle Fullscreen / Floating Panes / Pane Frames. |
| `ctrl+w v/s/q` | VSCodium | Split Vertical / Horizontal / Close Editor. |

---

## 🛠️ System & Abbreviations

### Fish Aliases (Modern Unix)
*   `cat` ⮕ `bat`
*   `find` ⮕ `fd`
*   `cd` ⮕ `z`
*   `du` ⮕ `dust -r`
*   `cp` ⮕ `rsync -ah --info=progress2`
*   `ls` / `ll` ⮕ `eza` (with icons & logical grouping)

### Specialized Tools
| Command | Action |
| :--- | :--- |
| `fkill` | Fuzzy find and kill processes (multi-select with Tab). |
| `py` / `pyr` | `uv run` / `uv run python`. |
| `copy` / `paste`| Wayland clipboard (`wl-copy`/`wl-paste`). |
| `pperf` / `pbal`| Asus Laptop: Performance / Balanced profiles. |
| `zk` | Zellij session manager (attach or create new). |
| `bmo` | Fuzzy find and open Bookmarks. |
