#!/bin/bash
# download theme
git submodule init && git submodule update --remote

# configuratin
cp ./themes/_config.yml themes/next/_config.yml