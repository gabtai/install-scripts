#!/bin/bash

# Megállás hiba esetén
set -e

echo "--- 1. Rendszer frissítése és csomagok telepítése ---"

# Rendszer és CachyOS specifikus eszközök
SYSTEM=(
    "linux-cachyos"
    "linux-cachyos-headers"
    "linux-firmware-amdgpu"
    "linux-firmware-realtek"
    "cachyos-settings"
    "cachyos-rate-mirrors"
    "iwd"
    "fakeroot"
    "xdg-user-dirs"
)

# AMD GPU Specifikus csomagok (RX 6750 XT)
# Mesa (OpenGL), Vulkan (RADV) és vkd3d (DX12 support)
GPU_AMD=(
    "mesa"
    "lib32-mesa"
    "vulkan-radeon"
    "lib32-vulkan-radeon"
    "libva-mesa-driver"
    "lib32-libva-mesa-driver"
    "vkd3d"
    "lib32-vkd3d"
)

# Gaming és Emuláció
GAMING=(
    "steam"
    "lutris"
    "wine-staging"
    "wine-mono"
    "winetricks"
    "gamemode"
    "lib32-gamemode"
    "mangohud"
    "goverlay"
)

# Megjelenés és Fontok
APPEARANCE=(
    "fastfetch"
    "papirus-icon-theme"
    "inter-font"
    "noto-fonts-emoji"
    "ttf-jetbrains-mono-nerd"
    "ttf-liberation"
)

# Eszközök
TOOLS=(
    "git"
    "mc"
    "nano"
    "nano-syntax-highlighting"
    "flatpak"
    "yay"
)

# Összesítés
ALL_PACKAGES=("${SYSTEM[@]}" "${GPU_AMD[@]}" "${GAMING[@]}" "${APPEARANCE[@]}" "${TOOLS[@]}")

# Telepítés
sudo pacman -Syu --needed --noconfirm "${ALL_PACKAGES[@]}"


echo "--- 2. Nano konfigurálása (~/.config/nano/nanorc) ---"
mkdir -p "$HOME/.config/nano"
cat <<EOF > "$HOME/.config/nano/nanorc"
include "/usr/share/nano/*.nanorc"
include "/usr/share/nano-syntax-highlighting/*.nanorc"

set linenumbers
set mouse
set softwrap
set indicator
set tabsize 4
EOF


echo "--- 3. Felhasználói könyvtárak létrehozása ---"
# Létrehozza a standard mappákat (Downloads, Documents, stb.)
xdg-user-dirs-update


echo "--- 4. Szolgáltatások aktiválása ---"
sudo systemctl enable --now iwd


echo "--- 5. Befejezés ---"
echo "Minden kész! Az RX 6750 XT készen áll a játékra (DX11, DX12, Vulkan)."
echo ""
echo "Emlékeztető systemd-boot felhasználóknak:"
echo "Ellenőrizd, hogy a boot config a vmlinuz-linux-cachyos fájlra mutat-e!"

