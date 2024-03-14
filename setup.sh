#!/bin/bash

#yum install -y ansible-core

# sudo http_proxy=http://127.0.0.1:54321 https_proxy=http://127.0.0.1:54321 ansible-pull -U https://github.com/caffeineaddiction/profile_setup.git -C "master" -e "target_user=${SUDO_USER:-$(whoami)}" --skip-tags vault -i localhost, setup.yml
ansible-pull -U https://github.com/caffeineaddiction/profile_setup.git -C "master" -e "target_user=${SUDO_USER:-$(whoami)}" --skip-tags vault -i localhost, setup.yml
