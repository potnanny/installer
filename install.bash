#!/bin/bash

#
# Install Potnanny application onto Raspberry Pi.
# This should be run as user 'pi', or another admin/superuser account.
#
# version 1.7   05/17/2024
# version 1.6   04/24/2024
# version 1.5   03/03/2024
# version 1.4   02/10/2024
# version 1.3   09/26/2023
# version 1.2   08/24/2023
# version 1.1   08/14/2023
# version 1.0   02/02/2023
#


echo ""
echo "=============================="
echo "POTNANNY INSTALLER        v1.7"
echo "=============================="
echo ""

## check if it is already installed?
if [[ -f "$HOME/venv/bin/potnanny" ]]
then
    echo "Potnanny is already installed."
    exit 1
fi


# check if an active install is in progress?
if [[ -f "$HOME/nohup.out" ]]
then
    secs=$(stat --printf="%Y" "$HOME/nohup.out")
    mins=$((($(date +%s) - ${secs%% *})/60))
    if [[ $mins > 180 ]]
    then
        rm "$HOME/nohup.out"
    else
        cat "$HOME/nohup.out" | grep "INSTALL COMPLETE"
        if [[ $? -eq 0 ]]
        then
            echo "Nothing to do"
            exit 0
        else
            echo "Install still in progress. If you want to monitor the install log, use command:"
            echo " tail -f $HOME/nohup.out"
            exit 1
        fi
    fi
fi


## update to latest pkgs, and install system requirements
echo ""
echo "UPDATING PACKAGES..."
echo "------------------------------"
touch $HOME/nohup.out
sudo apt update -y


echo ""
echo "INSTALLING REQUIREMENTS..."
echo "------------------------------"
sudo apt install build-essential libffi-dev libssl-dev python3-dev python3-pip python3-venv sqlite3 git ufw nginx -y


## create custom groups and assign to user
echo ""
echo "CREATING GROUPS..."
echo "------------------------------"
sudo groupadd -f potnanny
sudo usermod -G potnanny -a $USER
sudo usermod -G bluetooth -a $USER


## create the virtualenv to install app into
if [[ ! -d "$HOME/venv" ]]
then
    echo ""
    echo "CREATING VIRTUALENV..."
    echo "------------------------------"
    cd $HOME
    python3 -m venv venv
    if [[ $? -ne 0 ]]
    then
        echo "FATAL: PYTHON VIRTUALENV CREATION FAILURE!"
        exit 1
    fi
fi


## download the db repair script
if [[ ! -f "$HOME/repair.bash" ]]
then
    echo ""
    echo "DOWNLOADING REPAIR TOOLS..."
    echo "------------------------------"
    cd $HOME
    wget https://raw.githubusercontent.com/potnanny/repair/main/repair.bash
fi


## set up custom user dirs
if [[ ! -d "$HOME/potnanny" ]]
then
    echo ""
    echo "CREATING USER DIRECTORIES..."
    echo "------------------------------"
    mkdir $HOME/potnanny
fi


if [[ ! -d "$HOME/potnanny/plugins" ]]
then
    echo ""
    echo "CLONING PLUGIN REPOSITORY..."
    echo "------------------------------"
    cd $HOME/potnanny
    git clone https://github.com/potnanny/plugins.git
fi


## set up flask/quart app secret
cat $HOME/.profile | grep "POTNANNY_SECRET"
if [[ $? -ne 0 ]]
then
    echo ""
    echo "CREATING FLASK APP SECRET..."
    echo "------------------------------"
    echo "export POTNANNY_SECRET=`LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 24`" >> $HOME/.profile
fi


## set up cron job to restart application
crontab -l
if [[ $? -ne 0 ]]
then
    echo ""
    echo "CREATING USER CRON FILE..."
    echo "------------------------------"
    sudo touch /var/spool/cron/crontabs/$USER
    sudo chmod 600 /var/spool/cron/crontabs/$USER
    sudo chown $USER /var/spool/cron/crontabs/$USER
    sudo chgrp crontab /var/spool/cron/crontabs/$USER
fi

crontab -l | grep potnanny
if [[ $? -ne 0 ]]
then
    echo ""
    echo "ADDING APPLICATION CRON JOBS..."
    echo "------------------------------"
    echo '@reboot bash -c "source $HOME/.profile; source $HOME/venv/bin/activate; potnanny start" >/dev/null 2>&1' | crontab
    echo '*/15 * * * * bash -c "source $HOME/.profile; source $HOME/venv/bin/activate; potnanny status || potnanny start" >/dev/null 2>&1' | crontab
    echo '*/16 * * * * grep -i "database is locked" $HOME/potnanny/errors.log && bash $HOME/repair.bash" >/dev/null 2>&1' | crontab
fi


## self signed cert for web server
if [[ ! -f "/etc/ssl/potnanny/private.key" ]]
then
    echo ""
    echo "GENERATING SELF-SIGNED CERTIFICATE..."
    echo "------------------------------"
    sudo mkdir /etc/ssl/potnanny
    sudo chmod 750 /etc/ssl/potnanny
    sudo chgrp potnanny /etc/ssl/potnanny

    sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/potnanny/private.key -out /etc/ssl/potnanny/certificate.crt -subj "/C=US/ST=RI/L=Providence/O=Potnanny Local/OU=Development/CN=potnanny.local"

    sudo chgrp potnanny /etc/ssl/potnanny/private.key
    sudo chmod 640 /etc/ssl/potnanny/private.key
fi


# customize nginx https proxy
cat /etc/nginx/nginx.conf | grep potnanny
if [[ $? -ne 0 ]]
then
    echo ""
    echo "CONFIGURING NGINX PROXY..."
    echo "------------------------------"
    printf "user www-data;\nworker_processes auto;\npid /run/nginx.pid;\ninclude /etc/nginx/modules-enabled/*.conf;\n\nevents {\n\tworker_connections 768;\n}\n\nhttp {\n\tserver {\n\t\tlisten 80\tdefault;\n\t\treturn 301\thttps://\$host\$request_uri;\n\t}\n\n\tserver {\n\t\tlisten\t443 ssl default_server;\n\t\tlisten\t[::]:443 ssl default_server;\n\t\tserver_name\tpotnanny;\n\t\tclient_max_body_size\t200M;\n\t\tssl_certificate\t\t/etc/ssl/potnanny/certificate.crt;\n\t\tssl_certificate_key\t\t/etc/ssl/potnanny/private.key;\n\t\tlocation / {\n\t\t\tproxy_pass\t\thttp://localhost:8080;\n\t\t\tproxy_set_header\t\tHost \$host;\n\t\t}\n\t}\n}\n" | sudo tee /etc/nginx/nginx.conf >/dev/null
fi


## set a new hostname
hostname | grep potnanny
if [[ $? -ne 0 ]]
then
    echo ""
    echo "SETTING NEW HOSTNAME..."
    echo "------------------------------"
    sudo hostnamectl set-hostname potnanny
fi


## set up firewall
echo ""
echo "CONFIGURING FIREWALL..."
echo "------------------------------"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 8080
sudo ufw allow 443
sudo ufw allow 8443
sudo ufw --force enable


## install the python modules and the app
cd $HOME
echo ""
echo "INSTALLING APPLICATION..."
echo "------------------------------"
echo "This may take up to 2 hours... please be patient."
echo "Device will reboot once finished."
echo "After reboot, point browser to https://potnanny.local"
echo "Initial login/password is 'admin/potnanny!'"
echo ""
date
nohup bash -c "source $HOME/venv/bin/activate && pip install potnanny && echo 'INSTALL COMPLETE' && date && sudo reboot now"
