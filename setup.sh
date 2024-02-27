#!/bin/bash

#yum install -y ansible-core

ansible-pull -U https://github.com/caffeineaddiction/profile_setup.git -C "master" -e "target_user=${SUDO_USER:-$(whoami)}" --skip-tags vault -i localhost, setup.yml
