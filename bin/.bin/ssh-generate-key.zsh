#!/bin/zsh

KEY_NAME=${1:-github_key}_rsa

# ssh-key generation
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/${KEY_NAME}

# ssh-key addition
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/${KEY_NAME}

# ssh-key permission
chmod 700 ~/.ssh
chmod 600 ~/.ssh/${KEY_NAME}
chmod 644 ~/.ssh/${KEY_NAME}.pub
chmod 644 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/known_hosts
chmod 644 ~/.ssh/config
