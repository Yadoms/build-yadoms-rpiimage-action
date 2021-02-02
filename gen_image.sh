#!/bin/sh

cd pi-gen

# Example for building a lite system
echo "IMG_NAME='Raspbian'" > config
touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES
sudo ./build-docker.sh

if [[ ! $# -eq 0 ]] ; then
	echo "Move resultig image to $1"
    mv deploy/* $1
fi
