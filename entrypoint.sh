#!/bin/bash
DEFAULT_USER=user
USER=${USER_NAME}

ID=${USER_ID:-1000}

if [ $ID -eq `id -u` ]; then
    exec "$@"
elif [ "$USER" == "$DEFAULT_USER"  ]; then
    #Not defaul uid
    usermod -u ${ID} ${USER}
    exec gosu $ID "$@"
else
    #Not defaul user
    userdel user
    useradd --shell /bin/bash --home-dir $WORKDIR -u $ID $USER
    adduser $USER sudo
    exec gosu $ID "$@"
fi
