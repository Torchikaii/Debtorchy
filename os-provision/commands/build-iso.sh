#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ISO_DIR="$SCRIPT_DIR/iso"
OUTPUT="$SCRIPT_DIR/debtorchy.iso"

if [ ! -d "$ISO_DIR" ]; then
    echo "Error: iso/ directory not found at $ISO_DIR"
    exit 1
fi

if ! command -v xorriso >/dev/null 2>&1; then
    echo "Error: xorriso not found. Run os-provision/apps/xorriso.sh first."
    exit 1
fi

if ! command -v apt-ftparchive >/dev/null 2>&1; then
    echo "Error: apt-ftparchive not found. Install apt-utils first."
    exit 1
fi

read -rp "Root password [admin]: " root_pass || true; root_pass="${root_pass:-admin}"
read -rp "pc password [admin]: " pc_pass || true; pc_pass="${pc_pass:-admin}"
read -rp "NAS username (empty for none): " nas_user || true
read -rsp "NAS password (empty for none): " nas_pass || true
echo ""

export ROOT_PASS="$root_pass" PC_PASS="$pc_pass" NAS_USER="$nas_user" NAS_PASS="$nas_pass"

echo "Staging ISO in temporary directory"
TMP_ISO="$(mktemp -d)"
trap 'rm -rf "$TMP_ISO"' EXIT

cp -a "$ISO_DIR/." "$TMP_ISO/"
cp -a "$SCRIPT_DIR/os-provision" "$TMP_ISO/os-provision"
cp -a "$SCRIPT_DIR/package-manager" "$TMP_ISO/package-manager"

echo "Baking credentials into preseed"
python3 - "$TMP_ISO/preseed.cfg" << 'PYEOF'
import os, re, sys

path = sys.argv[1]
root_pass = os.environ.get('ROOT_PASS', '')
pc_pass = os.environ.get('PC_PASS', '')
nas_user = os.environ.get('NAS_USER', '')
nas_pass = os.environ.get('NAS_PASS', '')

with open(path) as f:
    content = f.read()

def shell_quote_single(s):
    return "'" + s.replace("'", "'\\''") + "'"

content = re.sub(r'(d-i passwd/root-password password ).*', lambda m: m.group(1) + root_pass, content)
content = re.sub(r'(d-i passwd/root-password-again password ).*', lambda m: m.group(1) + root_pass, content)
content = re.sub(r'(d-i passwd/user-password password ).*', lambda m: m.group(1) + pc_pass, content)
content = re.sub(r'(d-i passwd/user-password-again password ).*', lambda m: m.group(1) + pc_pass, content)

if nas_user and nas_pass:
    creds = (
        "printf 'username=%s\\npassword=%s\\n' "
        + shell_quote_single(nas_user) + " " + shell_quote_single(nas_pass)
        + " > /target/home/pc/.smbcredentials-nas2; "
        + "chown pc:pc /target/home/pc/.smbcredentials-nas2; "
        + "chmod 600 /target/home/pc/.smbcredentials-nas2; \\"
    )
    content = content.replace('@@NAS_CREDS@@', creds)
else:
    content = '\n'.join(line for line in content.split('\n') if '@@NAS_CREDS@@' not in line)

with open(path, 'w') as f:
    f.write(content)
PYEOF

echo "Regenerating package index"
cd "$TMP_ISO"
apt-ftparchive packages pool/main | awk 'BEGIN{RS=""; ORS="\n\n"} { if (match($0, /Filename: [^\n]*\.deb/)) print $0 }' > dists/trixie/main/binary-amd64/Packages
gzip -k -9 -f dists/trixie/main/binary-amd64/Packages
apt-ftparchive release \
    -o APT::FTPArchive::Release::Origin=Debian \
    -o APT::FTPArchive::Release::Label=Debian \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Version=13.4 \
    -o APT::FTPArchive::Release::Codename=trixie \
    -o APT::FTPArchive::Release::Component=main \
    -o APT::FTPArchive::Release::Architecture=amd64 \
    dists/trixie/main/binary-amd64 > dists/trixie/main/binary-amd64/Release
apt-ftparchive release \
    -o APT::FTPArchive::Release::Origin=Debian \
    -o APT::FTPArchive::Release::Label=Debian \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Version=13.4 \
    -o APT::FTPArchive::Release::Codename=trixie \
    -o APT::FTPArchive::Release::Components='main contrib' \
    -o APT::FTPArchive::Release::Architectures=amd64 \
    dists/trixie > dists/trixie/Release

echo "Regenerating md5sum.txt"
find . -type f ! -name md5sum.txt -not -path './isolinux/*' -print0 | sort -z | xargs -0 md5sum > "$TMP_ISO.md5sum.txt"
mv "$TMP_ISO.md5sum.txt" "$TMP_ISO/md5sum.txt"

echo "Building $OUTPUT"
xorriso \
  -as mkisofs \
  -r -J -joliet-long \
  -V "Debian Netinst" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -isohybrid-gpt-basdat \
  -o "$OUTPUT" \
  "$TMP_ISO"

echo "Done: $OUTPUT"
