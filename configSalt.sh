#!/bin/bash

# Make sure to set your Salt master
saltMaster="10.0.0.7"

# Set logFile
logFile="/root/saltSetup.log"
echo ${logFile}

echo -e "Beginning salt Install and config. This could take a couple of minutes (per host)\r\n"
# Get RPM or DEB-based
if [ -f /etc/redhat-release ]; then
    osType="RPM"
    echo "OS Type is $osType" >> $logFile
else
    osType="DEB"
    echo "osType is $osType" >> $logFile
fi


# Install RPM-based
if [ $osType = "RPM" ]; then
    `rpm -qa | grep salt-minion 2>&1>/dev/null`
    if [[ $? -ne 0 ]]; then
        echo -n "Setting up Salt Yum repos and installing RPMs. . .\r\n" | tee -a $logFile
        yum -y install https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm | tee -a $logFile
        yum -y install salt-minion | tee -a $logFile
        numPkgs=`rpm -qa | grep salt | grep -v mail | wc -l`
        if [ $numPkgs -eq 3 ]; then
            echo "Salt installed Successfully" >> $logFile
        else
            echo "Salt was not installed" >> $logFile
        fi
    else
        echo "Salt already installed" >> $logFile
    fi
fi

if [ $osType = "DEB" ]; then
    /usr/bin/dpkg -l | grep salt-minion | grep ii 2>&1>/dev/null
    if [[ $? -ne 0 ]]; then
        echo -n "Setting up Salt apt.sources.list and installing DPKGs. . .\r\n" | tee -a $logFile
        cd /tmp
        export DEBIAN_FRONTEND=noninteractive
        wget -O - https://repo.saltstack.com/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add - | tee -a $logFile
        echo "deb http://repo.saltstack.com/apt/debian/9/amd64/latest stretch main" >> /etc/apt/sources.list.d/saltstack.list | tee -a $logFile
        apt-get update
        apt-get -y install gcc-8-base -o Dpkg::Options::=--force-confnew
        apt-get -y install salt-minion
        numPkgs=`dpkg -l | grep salt | grep ^ii | wc -l`
        if [ $numPkgs -eq 2 ]; then
            echo "Salt installed successfully" >> $logFile
        else
            echo "Salt was not installed" >> $logFile
        fi
    else
        echo "Salt already installed" >> $logFile
    fi
fi

# Add minion host to /etc/hosts
echo -n "Adding salt entry to /etc/hosts. . .\r\n" | tee -a $logFile
sudo echo "${saltMaster} salt" | tee -a /etc/hosts

# Configure salt minion
echo -n "Adding salt master entr to /etc/salt/minion. . .\r\n" | tee -a $logFile
sudo echo -e "+ master: $saltMaster" | tee -a /etc/salt/minion

# Enable and sart salt minion
echo -n "Enabling salt-minion for systemctl. . .\r\n" | tee -a $logFile
sudo systemctl enable salt-minion && sudo systemctl start salt-minion

echo -n "Salt installed and configured successfully. Remember to run salt-key on the master.\r\n" | tee -a $logFile
