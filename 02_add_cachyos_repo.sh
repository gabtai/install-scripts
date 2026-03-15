#!/bin/bash

# Hibakezelés: ha bármi elromlik, álljon meg a script
set -e

echo "--- CachyOS Repozitórium Telepítése ---"

# 1. Letöltés a /tmp mappába, hogy ne szemeteljük össze az aktuális könyvtárat
cd /tmp

echo "Letöltés..."
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz

# 2. Kicsomagolás
echo "Kicsomagolás..."
tar xvf cachyos-repo.tar.xz

# 3. Belépés és futtatás
cd cachyos-repo
echo "Telepítő indítása..."
sudo ./cachyos-repo.sh

# 4. Takarítás (opcionális, de ajánlott)
echo "Takarítás..."
cd /tmp
rm -rf cachyos-repo cachyos-repo.tar.xz

echo "--- Kész! A CachyOS repók hozzáadva. ---"
