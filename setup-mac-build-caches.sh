#!/usr/bin/env bash
# Once per Mac: ccache for the C, C++ and Objective-C compiles of the Expo apps' native builds, shared by every worktree
# (not Swift, not Gradle's CMake tasks). A Mac without it builds the same apps, only slower. Safe to run again.
#
#   ./setup-mac-build-caches.sh [worktrees-folder]   the folder holding the worktrees, default ~/.t3/worktrees
set -euo pipefail

worktrees="${1:-$HOME/.t3/worktrees}"
case "$worktrees" in
  /*) ;;
  *) printf 'the worktrees folder must be an absolute path: %s\n' "$worktrees" >&2; exit 2 ;;
esac

command -v ccache > /dev/null || brew install ccache
ccache="$(command -v ccache)"

# Environment variables, in the file every zsh reads, agents' shells included. A ccache.conf wouldn't reach the compiles:
# React Native's Xcode wrapper points ccache at its own config file, and Xcode doesn't hand CCACHE_BINARY to the compiler.
# CCACHE_BASEDIR and CCACHE_NOHASHDIR keep a worktree's path out of the hash; with CCACHE_FILECLONE a hit is an APFS clone
# of the cached object, not a copy.
if grep -qs CCACHE_BASEDIR "$HOME/.zshenv"; then
  printf '~/.zshenv already sets up ccache: left as it is\n'
else
  cat >> "$HOME/.zshenv" <<ZSHENV

# ccache for native builds in every worktree (setup-mac-build-caches.sh in dahu33/conventions).
if [ -x $ccache ]; then
  export USE_CCACHE=1 CCACHE_BINARY=$ccache
  export CCACHE_BASEDIR="$worktrees" CCACHE_NOHASHDIR=1 CCACHE_FILECLONE=1 CCACHE_MAXSIZE=20G
  export CMAKE_C_COMPILER_LAUNCHER=ccache CMAKE_CXX_COMPILER_LAUNCHER=ccache
fi
ZSHENV
  printf 'added the ccache block to ~/.zshenv\n'
fi

# DerivedData at ios/DerivedData in each worktree: the same relative path everywhere, so the compiles hash alike, and it
# leaves with the worktree.
defaults write com.apple.dt.Xcode IDECustomDerivedDataLocation -string DerivedData

printf 'Done. Open a new shell; an ios/ installed before this needs pod install again. ccache -s shows the hits.\n'
