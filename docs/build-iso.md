```bash
sudo rm -rf debian-iso-extracted 
mkdir debian-iso-extracted
mount -o loop debtorchy.iso debian-iso-extracted
cp -a debian-iso-extracted/* ./iso
umount debian-iso-extracted
```

```bash
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
  -o debtorchy.iso \
  iso/
```
