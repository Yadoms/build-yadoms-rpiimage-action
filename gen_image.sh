#!/bin/sh

DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"


#retreive version from currently built file
pwd
ls -al
export yadomsVersion=`ls package/Yadoms*.tar.gz | head -1 | grep -oP '(?<=-).*(?=-)'`
echo "Found Yadoms : $yadomsVersion"

cd pi-gen

# Generate FR image
sudo cp $DIR/config_fr ./config

# disable stage 3, 4 and 5
sudo touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
sudo touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

# copy stage99
if [ -d "$DIR/stage99" ]; then
	sudo rm -Rf $DIR/stage99
fi
sudo cp -rp $DIR/stage99 .
sudo cp ../package/Yadoms-$yadomsVersion-RaspberryPI.tar.gz ./stage99/03-yadoms/yadoms.tar.gz
sudo chmod 777 ./stage99/03-yadoms/yadoms.tar.gz

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
