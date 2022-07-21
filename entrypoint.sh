#!/bin/bash

USER=user
ID=${USER_ID:-1000}

if [ $ID -eq `id -u` ]; then
    exec "$@"
else
    useradd --shell /bin/bash --home-dir $WORKDIR -u $ID $USER
    exec gosu $USER "$@"
fi
