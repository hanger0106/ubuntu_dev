#!/bin/bash

USER=${USER_NAME:-user}
ID=${USER_ID:-1000}

if [ $ID -eq `id -u` ]; then
    exec "$@"
else
    #Not defaul user
    userdel -r user
    useradd --shell /bin/bash --home-dir $WORKDIR -u $ID $USER
    adduser $USER sudo
    exec gosu $ID "$@"
fi
