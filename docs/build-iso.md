### Building the .iso file

In order to build the iso file from `iso/` directory you can
use the `./os-provision-commands/build-iso.sh` helper script.


### Extracting the .iso file

If for some reason you will decide to extract the .iso file you
built, you can use the following commands:

```bash
sudo rm -rf debian-iso-extracted 
mkdir debian-iso-extracted
mount -o loop debtorchy.iso debian-iso-extracted
cp -a debian-iso-extracted/. ./iso
umount debian-iso-extracted
```
The `.gitignore` file handles all of the temporary extraction
folders properly, so you don't need to worry about them.
