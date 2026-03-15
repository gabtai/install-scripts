#!/bin/bash

# 1. Szükséges Arch Linux csomagok telepítése
echo "--- Csomagok telepítése (zsh, completions, syntax-highlighting)..."
sudo pacman -S --needed zsh zsh-completions zsh-syntax-highlighting git

# 2. A saját konfigurációd letöltése
echo "--- Konfigurációs fájlok másolása a /home mappába..."
cd /tmp
# Töröljük, ha esetleg már ott lenne egy korábbi futtatásból
rm -rf zsh 
git clone --depth 1 https://github.com/gabtai/zsh

# Fájlok átmásolása a felhasználó home mappájába
cp -rv zsh/. "$HOME/"

# Takarítás a /tmp mappában
rm -rf zsh

# 3. Plugin mappa létrehozása
PLUGIN_DIR="$HOME/.config/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

# 4. Extra repository-k klónozása
echo "--- Sindresorhus/pure és Zsh-async klónozása..."

# Pure prompt klónozása (Javított szóköz!)
if [ ! -d "$PLUGIN_DIR/pure" ]; then
    git clone --depth 1 https://github.com/sindresorhus/pure "$PLUGIN_DIR/pure"
else
    echo "A 'pure' már létezik, frissítés..."
    git -C "$PLUGIN_DIR/pure" pull
fi

# Zsh-async klónozása
if [ ! -d "$PLUGIN_DIR/zsh-async" ]; then
    git clone --depth 1 https://github.com/mafredri/zsh-async "$PLUGIN_DIR/zsh-async"
else
    echo "A 'zsh-async' már létezik, frissítés..."
    git -C "$PLUGIN_DIR/zsh-async" pull
fi

# 5. Befejezés és Shell váltás
echo "--- Telepítés befejezve."
# Ellenőrizzük, hogy valóban zsh-ban vagyunk-e már
if [[ "$SHELL" != *"/zsh" ]]; then
    echo "Szeretnéd a Zsh-t beállítani alapértelmezettnek? (i/n)"
    read -r response
    if [[ "$response" =~ ^([iI][gG][eE][nN]|[iI])$ ]]; then
        sudo chsh -s $(which zsh) $USER
        echo "Alapértelmezett shell módosítva. Kérlek, jelentkezz ki és be!"
    fi
fi

echo "Kész! Indíts egy új terminált a változásokhoz."

