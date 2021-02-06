#!/bin/sh

#Retreive current folder (folder of current script, not working folder)
DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

#manage command line arguements
LANG=EN
DEPLOY_TO_CUSTOM_DIR=NO
YADOMS_BINARY_PATH=package

for i in "$@"
do
case $i in
    -lfr|--lang_french)
    LANG=FR
    shift
    ;;
    -len|--lang_english)
    LANG=EN
    shift
    ;;
    -d=*|--deploy=*)
    DEPLOY_TO_CUSTOM_DIR=YES
    DEPLOY_DIR="${i#*=}"
    shift
    ;;
    -y=*|--yadoms-path=*)
    YADOMS_BINARY_PATH="${i#*=}"
    shift
    ;;
    *)
          # unknown option
    ;;
esac
done

echo "path= ${YADOMS_BINARY_PATH}"
ls -al
pwd
ls -al builds

#retreive version from currently built file
export yadomsVersion=`ls ${YADOMS_BINARY_PATH}/Yadoms*.tar.gz | head -1 | grep -oP '(?<=-).*(?=-)'`
echo "Found Yadoms : $yadomsVersion"

cd pi-gen

if [ $LANG = "FR" ]; then
	# Generate FR image
	sudo cp $DIR/config_fr ./config
else
	# Generate EN image
	sudo cp $DIR/config_en ./config
fi

# disable stage 3, 4 and 5 from pi-gen
sudo rm -Rf stage3
sudo rm -Rf stage4
sudo rm -Rf stage5
#sudo touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
#sudo touch ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

#disable generation of raspbian-lite image (our custom stage will generate raspbian-lite-yadoms)
#sudo touch ./stage2/SKIP_IMAGES 

# copy stage99
if [ -d "stage99" ]; then
	sudo rm -Rf stage99
fi

sudo cp -rp $DIR/stage99 .
sudo cp ../package/Yadoms-$yadomsVersion-RaspberryPI.tar.gz ./stage99/02-yadoms/yadoms.tar.gz
sudo chmod 777 ./stage99/02-yadoms/yadoms.tar.gz
sudo mv stage99 stage3

if [ -d "work" ]; then
	sudo rm -Rf work
fi

# generate image
sudo ./build-docker.sh

#delete
sudo docker rm -v pigen_work || true

if [ $DEPLOY_TO_CUSTOM_DIR = "YES" ]; then
	if [ ! -d "${DEPLOY_DIR}" ]; then
	  echo "Creating folder ${DEPLOY_DIR}"
	  mkdir -p ${DEPLOY_DIR}
	fi
	
	echo "Move resultig image to ${DEPLOY_DIR}"
    	sudo mv deploy/* ${DEPLOY_DIR}
	sudo chmod -R 777 ${DEPLOY_DIR}
else
	echo "No output folder provided"
	echo "Deploy folder is $(pwd)/deploy"
fi



