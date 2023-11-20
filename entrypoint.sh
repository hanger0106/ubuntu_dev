#!/bin/bash

USER=${USER_NAME:-user}
ID=${USER_ID:-1000}

if [ $ID -eq `id -u` ]; then
    exec "$@"
else
    useradd --shell /bin/bash --home-dir $WORKDIR -u $ID $USER
    usermod -u $ID $USER
    exec gosu $ID "$@"
fi
