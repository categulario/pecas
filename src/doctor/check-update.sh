#!/bin/sh

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
    echo "=> Pecas está actualizado."
elif [ $LOCAL = $BASE ]; then
    echo "=> Se ha detectado una nueva versión."
    echo "   Para actualizar usa:"
    echo "   pc-doctor --update"
else
    echo "=> Se ha detectado una divergencia."
    echo "   Para corregirla usa:"
    echo "   pc-doctor --restore"
fi

echo "-------------------------------------"
