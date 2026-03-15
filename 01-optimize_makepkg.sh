#!/bin/bash

# Színkódok a visszajelzéshez
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CONF="/etc/makepkg.conf"
BACKUP="/etc/makepkg.conf.bak.$(date +%F_%H%M%S)"

echo -e "${YELLOW}Sway + nwg-shell (CachyOS alapú) optimalizáció indítása...${NC}"

# 0. Sudo ellenőrzés
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Hiba: Ezt a scriptet sudo-val kell futtatni!${NC}"
  exit 1
fi

# 1. Függőségek ellenőrzése és telepítése (ccache)
if ! pacman -Qs ccache > /dev/null; then
    echo -e "${YELLOW}A ccache nincs telepítve. Telepítés folyamatban...${NC}"
    pacman -S --noconfirm ccache
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}ccache sikeresen telepítve.${NC}"
    else
        echo -e "${RED}Hiba történt a ccache telepítésekor!${NC}"
        exit 1
    fi
fi

# 2. Ccache méretének beállítása (15GB) a rendes felhasználóhoz
if [ -n "$SUDO_USER" ]; then
    sudo -u "$SUDO_USER" ccache -M 15G
    echo -e "${GREEN}Ccache mérete 15GB-ra állítva ($SUDO_USER számára).${NC}"
else
    ccache -M 15G
    echo -e "${GREEN}Ccache mérete 15GB-ra állítva.${NC}"
fi

# 3. Biztonsági mentés a makepkg.conf-ról
cp "$CONF" "$BACKUP"
echo -e "${GREEN}Biztonsági mentés készült:${NC} $BACKUP"

# 4. Módosítások alkalmazása a makepkg.conf-ban

# RAM-ban való fordítás (BUILDDIR) élesítése
sed -i 's|^#BUILDDIR=/tmp/makepkg|BUILDDIR=/tmp/makepkg|' "$CONF"

# Ccache aktiválása a BUILDENV-ben (!ccache -> ccache)
sed -i '/^BUILDENV=/ s/!ccache/ccache/' "$CONF"

# LTO szálak fixálása az összes magra (auto -> nproc)
sed -i "s/LTOFLAGS=\"-flto=auto\"/LTOFLAGS=\"-flto=$(nproc)\"/" "$CONF"

# Tömörítés kiiktatása (PKGEXT módosítás .pkg.tar-ra)
sed -i "s/^PKGEXT=.*/PKGEXT='.pkg.tar'/" "$CONF"

# Rust optimalizáció hozzáadása a fájl végére, ha még nincs benne
if ! grep -q "RUSTFLAGS" "$CONF"; then
    echo -e "\n# Rust optimalizáció a native CPU-hoz\nRUSTFLAGS=\"-C target-cpu=native -C opt-level=3\"" >> "$CONF"
fi

echo -e "---------------------------------------------------"
echo -e "${GREEN}OPTIMALIZÁLÁS KÉSZ!${NC}"
echo -e "Az AUR frissítések (Sway, nwg-shell) mostantól:"
echo -e " 1. A ${YELLOW}RAM-ban${NC} készülnek (/tmp/makepkg)"
echo -e " 2. Használják a ${YELLOW}ccache${NC}-t a gyorsabb újrafordításhoz"
echo -e " 3. ${YELLOW}Nem vesztegetik az időt${NC} a csomag tömörítésére a végén"
echo -e "---------------------------------------------------"
