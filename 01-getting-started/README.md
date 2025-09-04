# 📁 📁 01 – Getting Started with Linux

This module introduces you to the Linux command line.  Knowing how to move around the filesystem and manipulate files is foundational for every other RHCSA objective.

## Topics covered

- **Shells and terminals** – Bash is the default shell on RHEL; open a terminal or virtual console with `Ctrl‑Alt‑F3`.
- **Filesystem hierarchy** – Learn the purpose of `/`, `/home`, `/etc`, `/var`, `/usr`, `/tmp` and `/dev`.
- **Navigation commands** – `pwd` shows the current directory, `cd` changes directory and `ls -l` lists files with details.
- **Creating and removing files** – `touch` creates empty files, `mkdir` makes directories, `rm` removes files and `rmdir` removes empty directories.
- **Viewing file contents** – Use `cat` to view a whole file, `less` for paging, and `head`/`tail` to show the beginning or end of a file.
- **Copying and moving** – `cp` copies files/directories; `mv` moves or renames them.
- **Wildcards and globs** – Use `*`, `?` and `[abc]` to match multiple files when working with commands.
- **Finding help** – `man` opens manual pages, `info` provides GNU documentation and `command --help` shows a quick summary.
- **Absolute vs relative paths** – `/etc/hosts` is absolute; `../somefile` is relative to the current directory.

## Practice

1. Log into your RHEL or CentOS system.
2. Create a practice area:
   ```bash
   mkdir -p ~/practice/intro/{files,logs}
   echo "Welcome to RHCSA practice" > ~/practice/intro/files/hello.txt
   ```
3. Navigate into the directory with `cd ~/practice/intro/files` and explore using `ls`, `cat hello.txt`, `cp`, `mv` and `rm`.
4. Use `man ls` and `ls --help` to explore the many options of the `ls` command.
5. Explore hidden files using `ls -a` and create dotfiles (e.g. `.bashrc`) in your home directory.
6. Try switching between TTYs with `Ctrl‑Alt‑F3`…`Ctrl‑Alt‑F6` and return to the graphical console with `Ctrl‑Alt‑F2`.

> **Tip:** Use `history` to recall previously executed commands and `!<number>` to rerun them.

Continue practicing until these commands feel natural.  The remaining modules build on this foundation.
