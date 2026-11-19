# Dotfiles

These dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level package mirrors its destination relative to the home directory.

## Install

Install Stow on macOS, clone this repository, and run the installer:

```sh
brew install stow
git clone https://github.com/owen-fuller/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install
```

The installer creates individual symlinks for the `aerospace`, `emacs`, and
`kitty` packages. To install only selected packages, pass their names:

```sh
./install emacs kitty
```

## Update

Existing symlinks point into the repository, so changes to existing files take
effect as soon as they are pulled. Run the installer again after a pull as a
safe default; `--restow` also picks up files that were added, moved, or removed:

```sh
git pull
./install
```

`--no-folding` keeps application-created state and caches in `~/.config`
instead of putting them inside this repository.

## Remove symlinks

From the repository root:

```sh
stow --delete --no-folding --target="$HOME" aerospace emacs kitty
```
