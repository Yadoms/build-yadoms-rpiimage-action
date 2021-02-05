# build-yadoms-rpiimage-action
Github action which generates RaspberryPI images

## Parameters:
	
* branch_or_tag_name : The branch or tag name of [RPi-Distro/pi-gen](https://github.com/RPi-Distro/pi-gen) to use (default master)
 
* output_folder : The output folder in which the resulting image is moved (if empty, image should be in pi-gen/deploy folder)

* language : The image default language. Default is en. Accepted value: fr
