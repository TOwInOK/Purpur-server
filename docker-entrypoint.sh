#!/bin/sh
set -e

DOCKER_USER='dockeruser'
DOCKER_GROUP='dockergroup'
USER_ID=${PUID:-9001}
GROUP_ID=${PGID:-9001}

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
    echo "First start of the docker container, start initialization process."
    
    echo "Starting with $USER_ID:$GROUP_ID (UID:GID)"
    
    addgroup --gid $GROUP_ID $DOCKER_GROUP
    adduser $DOCKER_USER --shell /bin/sh --uid $USER_ID --ingroup $DOCKER_GROUP --disabled-password --gecos ""
    
    chown -vR $USER_ID:$GROUP_ID /opt/minecraft
    chmod -vR ug+rwx /opt/minecraft
    
    if [ "$SKIP_PERM_CHECK" != "true" ]; then
        chown -vR $USER_ID:$GROUP_ID /data
    fi
fi

export HOME=/home/$DOCKER_USER

exec gosu $DOCKER_USER:$DOCKER_GROUP java --$PUFFER_FLAGS -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE $JAVAFLAGS /opt/minecraft/purpur.jar $ADD_FLAGS nogui
 
