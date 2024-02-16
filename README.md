# Installer
Installation script for the potnanny greenhouse controller for raspberry pi

## Prerequisites
- Potnanny requires Python 3.11
- Raspberry Pi OS, Debian version: 12 (bookworm) or higher is recommended.
- Must be connected to the internet.

## Usage
1. Ssh to your raspberry pi from a terminal (Mac and Linux computers can use their built in Terminal app. On Windows I recommend MobaXterm)
*your existing pi hostname may be different*
```
[terminal]$ ssh pi@raspberrypi.local
pi@raspberrypi password: ***********
[pi@raspberrypi]$
```
You are now connected and logged into the raspberry pi!

2. Download the install script from GitHub
```
[pi@raspberrypi]$ wget https://raw.githubusercontent.com/potnanny/installer/main/install.bash
[pi@raspberrypi]$
```

3. Run the install script
```
[pi@raspberrypi]$ bash ./install.bash
```

Get a cup of coffee, go for a walk, watch some TV, something...
*There is a lot of software that needs to be downloaded, updated, and compiled during the install. This can take up to 1.5 hours on low-horsepower devices like the Raspberry Pi Zero W. Please be patient.*


## Post Install
After the install is completed, the raspberry pi will reboot. Wait a few minutes to allow the Pi to restart, and re-establish it's network connections.

Ensure your bluetooth devices are powered up and located near the Raspberry Pi.

1. Open a web browser on your mobile or laptop, and go to https://potnanny.local (if this address cannot be reached on your wifi network, you may need to use the IP address of the raspberry pi. You will need to get this info from your home wifi router admin page)
2. Your web browser will alert you to potential certficate problem with the site. Its ok. Accept and continue. (This is just because your local potnanny web server is using a self-signed certificate to encrypt traffic, and this certificate cannot be verified on the internet)
3. Login username = admin, password = potnanny!
4. Reset the password to something else from the **Account** -> **Change Password** menu
5. On the main page, press the "+" button to add a new Room
6. Navigate to **Settings** -> **Devices** -> **Discover New Devices** and answer Yes
7. Navigate to **Settings** -> **Devices** -> **Device List**
8. Wait for newly scanned devices to appear on the page. When they do, click on each one and assign it to the room that you created in step 3. click Save.
9. Click the POTNANNY menu to return to the home page. Room measurements will begin poplulating on the main dashboard page.
