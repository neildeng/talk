#!/bin/bash +x
set -e

cd "$(dirname "$0")"
sudo hostctl add talk --from ./hosts 
