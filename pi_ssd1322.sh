cd

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y git bc i2c-tools libncurses-dev flex bison libssl-dev
sudo apt-get install -y raspberrypi-kernel-headers

zgrep "* firmware as of" /usr/share/doc/raspberrypi-bootloader/changelog.Debian.gz | head -1 | awk '{ print $5 }'

## in a browser get that commit value - plug it in here - and get the returned hash 
https://github.com/raspberrypi/firmware/commit/74c4307951701f93bd94b4fd37e6adc44910d6e0/extra/git_hash

# for example - that returns 315314059f92c13bc7d34b6aaff7527aca68457c

# prob doesnt need to be sudo here
cd ~/
sudo wget https://github.com/raspberrypi/linux/archive/315314059f92c13bc7d34b6aaff7527aca68457c.tar.gz
sudo gunzip 315314059f92c13bc7d34b6aaff7527aca68457c.tar.gz
sudo tar -xvf 315314059f92c13bc7d34b6aaff7527aca68457c.tar
sudo mv linux-315314059f92c13bc7d34b6aaff7527aca68457c linux
sudo rm 315314059f92c13bc7d34b6aaff7527aca68457c.tar
sudo chown -R pi:pi linux


# get the fb_ssd1322 driver
git clone https://github.com/okyeron/ssd1322-linux.git
cd ssd1322-linux
cp -f drivers-staging-fbtft/* ~/linux/drivers/staging/fbtft/
sudo dtc -W no-unit_address_vs_reg -@ -I dts -O dtb -o /boot/overlays/ssd1322w-spi.dtbo /home/pi/ssd1322-linux/overlay/ssd1322w-overlay.dts

cd ~/linux


cp -f /usr/src/linux-headers-$(uname -r)/Module.symvers .
cp -f /home/pi/ssd1322-linux/linux-pizero-5.10.103+/.config .
cp -f /home/pi/ssd1322-linux/linux-pizero-5.10.103+/Makefile .

#cp -f /usr/src/linux-headers-$(uname -r)/.config .

# ADD + to EXTRAVERSION in Makefile

#KERNEL=kernel7 #Pi 2, 3, 3+ and Zero 2 W,
KERNEL=kernel # pi zero
#make mrproper
make bcmrpi_defconfig # pi zero / zero w

make menuconfig
##        Device Drivers  ---> Staging Drivers ---> Support for small TFT LCD display modules  --->
##        <M>   SSD1322 driver


make modules_prepare

#make prepare

## compile the drivers    
#make -C ~/linux SUBDIRS=drivers/staging/fbtft modules
make -C ~/linux M=drivers/staging/fbtft

## move the drivers    
sudo cp -v ~/linux/drivers/staging/fbtft/*.ko /lib/modules/$(uname -r)/kernel/drivers/staging/fbtft/
sudo depmod -a

#rm ~/.config

sudo reboot
