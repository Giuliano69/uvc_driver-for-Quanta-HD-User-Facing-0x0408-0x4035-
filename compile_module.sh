#!/bin/bash 
#Test linux distribution and version
source /etc/os-release
if [ "$ID" != "ubuntu" ]; then 
	echo "Sorry, this script works only for Ubuntu distribution"
	exit
fi

if [ "$VERSION_ID" != "22.04" ]; then 
	echo "Sorry, this script works only for Ubuntu 22.04 LTS"
	exit
fi


sudo apt update # update package list
sudo apt upgrade # upgrade packages
sudo apt install build-essential -y # install tools needed for module compilation

#get driver code to compile a patch it
cd ~  # change to your home directory
apt-get source linux-modules-extra-$(uname -r)  #download in your home, the kernel source file version that match your used kernel
cd ~/linux-*/drivers/media/usb/uvc # change to the currently created uvc directory
mv uvc_driver.c uvc_driver.old  # rename/backup the uvc driver soruce file, that need to be updated
wget https://raw.githubusercontent.com/Giuliano69/uvc_driver-for-Quanta-HD-User-Facing-0x0408-0x4035-/main/uvc_driver.c # download the updated driver source file

#compile and install
make -j4 -C /lib/modules/$(uname -r)/build M=$(pwd) modules  # complie the updated video modules for your kernel version
sudo cp uvcvideo.ko /lib/modules/$(uname -r)/kernel/drivers/media/usb/uvc/  #install the video driver module in the system
sudo rmmod uvcvideo && sudo modprobe uvcvideo
#reboot  #reboot to check your camera is working



