#!/bin/sh
pwd
ls -al

cd pi-gen

# Generate FR image
sudo cp ../config_fr ./config

# disable stage 3, 4 and 5
sudo touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
sudo touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

# copy stage99
sudo cp -rp ../stage99 .

# generate image
sudo ./build-docker.sh

if [ ! $# -eq 0 ]; then
	if [ ! -d "$1" ]; then
	  echo "Creating folder $1"
	  mkdir -p $1
	fi
	
	echo "Move resultig image to $1"
    sudo mv deploy/* $1
	sudo chmod -R 777 $1
else
	echo "No output folder provided"
	echo "Deploy folder is $(pwd)/deploy"
fi
