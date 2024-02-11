# Installer
Installation script for the potnanny greenhouse controller for raspberry pi

## Prerequisites
- Potnanny requires Python 3.11
- Raspberry Pi OS, Debian version: 12 (bookworm) or higher is recommended.
- Must be connected to the internet.

## Usage
1. Ssh to your raspberry pi from a terminal (Terminal app on Mac and Linux, on Windows I recommend MobaXterm)
*your existing pi hostname may be different*
```
[terminal]$ ssh pi@raspberrypi.local
pi@raspberrypi password: ***********
[pi@raspberrypi]$
```

2. Download the install script from GitHub
```
[pi@raspberrypi]$ wget https://raw.githubusercontent.com/potnanny/installer/main/install.bash
[pi@raspberrypi]$
```

3. Run the install script
```
[pi@raspberrypi]$ bash ./install.bash
```

4. Answer the webserver self-signed certificate questions.
Most of these fields can be left blank. However, the following should be populated:
    - Country. Enter your 2 letter country code (like, US) [Wiki List](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
    - Organization Name. Enter Potnanny
```
Country Name (2 letter code) [AU]: US
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]: Potnanny
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:
Email Address []:
```

5. Answer firewall startup question
```
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
```

## Post Install
After the install is completed, the raspberry pi will reboot. Wait a few minutes to allow the Pi to restart, and re-establish it's network connections.

Ensure your bluetooth devices are powered up and located near the Raspberry Pi.

1. Open a web browser on your mobile or laptop, and go to https://potnanny.local (if this does not work, you may need the IP address from your wifi router admin page)
2. Login username = admin, password = potnanny!
3. Reset the password to something else from the **Account** -> **Change Password** menu
3. On the main page, press the "+" button to add a new Room
4. Navigate to **Settings** -> **Devices** -> **Scan New Devices** and answer Yes
5. Navigate to **Settings** -> **Devices** -> **Device List**
6. Wait for newly scanned devices to appear on the page. When they do, click on each one and assign it to the room that you created in step 3. click Save.
7. Click the POTNANNY menu to return to the home page. Room measurements will begin poplulating on the main dashboard page.
