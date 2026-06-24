#!/bin/bash
set -e

# falcond - Install script for Void Linux with runit
# This script builds and installs falcond on Void Linux

FALCOND_VERSION="2.0.8"
FALCOND_REPO="https://github.com/PikaOS-Linux/falcond-profiles.git"

echo "==> Installing build dependencies..."
xbps-install -Sy git dbus zig sudo power-profiles-daemon scx

echo "==> Building falcond..."
cd "$(dirname "$0")/falcond"

ZIG=${ZIG:-zig}
if ! "$ZIG" version | grep -q "0.16"; then
    echo "zig 0.16.0 is required. Install it first:"
    echo "  Download from https://ziglang.org/download/"
    echo "  Or use: curl -sL https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz | tar -xJ"
    exit 1
fi

"$ZIG" build -Doptimize=ReleaseFast -Dcpu=x86_64_v3

echo "==> Installing binary..."
install -Dm755 zig-out/bin/falcond /usr/bin/falcond

echo "==> Installing profiles..."
rm -rf /tmp/falcond-profiles
git clone --depth 1 "$FALCOND_REPO" /tmp/falcond-profiles
mkdir -p /usr/share/falcond
cp -r /tmp/falcond-profiles/usr/share/falcond/* /usr/share/falcond/
rm -rf /tmp/falcond-profiles

echo "==> Creating directories..."
mkdir -p /etc/falcond
mkdir -p /var/lib/falcond

echo "==> Installing runit service..."
install -Dm755 ../runit/falcond/run /etc/sv/falcond/run
[ -f ../runit/falcond/conf ] && install -Dm644 ../runit/falcond/conf /etc/sv/falcond/conf

echo "==> Enabling runit service..."
ln -sf /etc/sv/falcond /var/service/

echo ""
echo "falcond $FALCOND_VERSION instalado correctamente en Void Linux."
echo "El servicio se ha habilitado via runit en /var/service/falcond."
echo "Para iniciarlo manualmente: sv start falcond"
echo ""
echo "Configuracion: /etc/falcond/config.conf"
echo "Profile:       /usr/share/falcond/profiles/"
echo "Estado:        /var/lib/falcond/status"
