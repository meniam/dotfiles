#! /bin/bash

echo "Start nginx install";

if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    apt install php8.1

else

    echo "Command NOT allowed on Linux Only"

fi


echo "Stop nginx install";