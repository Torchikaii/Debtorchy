#!/bin/bash

set -e

chown -R pc:pc /home/pc || echo "WARNING: chown /home/pc before provisioning failed" >&2

MAIN_SCRIPT="${MAIN_SCRIPT:-/home/pc/repos/Debtorchy/os-provision/main.sh}"

main_status=0
if ! bash "$MAIN_SCRIPT"; then
    main_status=$?
fi

chown -R pc:pc /home/pc || echo "WARNING: chown /home/pc after provisioning failed" >&2

if [ "$main_status" -ne 0 ]; then
    echo "provisioning ($MAIN_SCRIPT) failed with status $main_status — incomplete, will retry on next boot. Logs: journalctl -u debtorchy-firstboot" >&2
    exit 0
fi

systemctl disable debtorchy-firstboot
rm -f /etc/systemd/system/debtorchy-firstboot.service
systemctl reboot
