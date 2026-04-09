#!/usr/bin/env bash

set -e

echo "python-packages.sh running"
echo "python system packages are being installed"

pip install -qq python-lsp-server

echo "python-packages.sh completed"
