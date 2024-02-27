#!/bin/bash

# ansible-core

/usr/bin/ansible-pull -U ssh://git@github.com:caffeineaddiction/profile_setup.git -e "target_user=${SUDO_USER:-$(whoami)}" setup.yml
