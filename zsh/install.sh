#!/usr/bin/env bash

function download_install_zsh() {
    zsh_pkg=zsh-5.9-4-x86_64.pkg.tar.zst
    rsync_pkg=rsync-3.4.1-1-x86_64.pkg.tar.zst
    libxxhash_pkg=libxxhash-0.8.3-1-x86_64.pkg.tar.zst
    msys_website=https://mirror.msys2.org/msys/x86_64

    if [ ! "$(command -v aria2c)" ]; then
        scoop install aria2c
    fi

    if [ ! "$(command -v zstd)" ]; then
        scoop install zstd
    fi

    # install zsh
    if [ ! "$(command -v zsh)" ]; then
        if [ ! -f $zsh_pkg ]; then
            aria2c $msys_website/$zsh_pkg
        fi
        tar -xf $zsh_pkg -C $HOME/scoop/apps/git/current/
    fi

    # install rsync
    if [ ! "$(command -v rsync)" ]; then
        if [ ! -f $libxxhash_pkg ]; then
            aria2c $msys_website/$libxxhash_pkg
        fi
        if [ ! -f $rsync_pkg ]; then
            aria2c $msys_website/$rsync_pkg
        fi
        tar -xf $libxxhash_pkg -C $HOME/scoop/apps/git/current/
        tar -xf $rsync_pkg -C $HOME/scoop/apps/git/current/
    fi
}

if [ ! "$(command -v git)" ]; then
    echo You need to install git first
    exit 1
fi

if [ -n "$OS" ]; then
    # On Windows, need git for windows installed
    download_install_zsh
fi

if [ ! "$(command -v zsh)" ]; then
    echo "zsh is not installed"
    exit 1
fi

if [ ! -d ~/.oh-my-zsh ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/jeffreytse/zsh-vi-mode ~/.oh-my-zsh/custom/plugins/zsh-vi-mode
    git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
fi

if [ ! -f ~/.zshrc ]; then
    cp $(pwd)/.zshrc ~/.zshrc
fi
