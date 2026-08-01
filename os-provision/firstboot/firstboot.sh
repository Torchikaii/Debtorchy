#!/bin/bash

set -e

bash /home/pc/repos/Debtorchy/os-provision/main.sh
chown -R pc:pc /home/pc
systemctl disable debtorchy-firstboot
rm -f /etc/systemd/system/debtorchy-firstboot.service
systemctl daemon-reload
systemctl reboot
