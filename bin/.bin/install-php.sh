#! /bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    apt install php8.1

elif [[ "$OSTYPE" == "darwin"* ]]; then

    brew install php@8.1

else
    echo 'Unknown OS!'
fi