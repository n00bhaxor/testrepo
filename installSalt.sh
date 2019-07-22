#!/bin/sh

# Make sure to set your Salt master
saltMaster="10.0.0.7"

# Set logFile
logFile="/root/saltSetup.log"
echo ${logFile}

# Get RPM or DEB-based
if [ -f /etc/redhat-release ]; then
    osType="RPM"
    echo "OS Type is $osType" >> $logFile
else
    osType="DEB"
    echo "osType is $osType" >> $logFile
fi


# Install RPM-based
if [ $osType == "RPM" ]; then
     yum -y install https://repo.saltstack.com/yum/redhat/salt-repo-2019.2-1.el7.noarch.rpm | tee -a $logFile
    yum -y install salt-minion | tee -a $logFile
    numPkgs = `rpm -qa | grep salt | grep -v mail | wc -l`
    if [ $numPkgs -eq 3 ]; then
        echo "Salt installed Successfully" >> $logFile
    else
        echo "Salt was not installed" >> $logFile
    fi
fi

if [ $osType == "DEB" ]; then
    cd /tmp
    wget -O - https://repo.saltstack.com/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add - | tee $logFile
    echo "deb http://repo.saltstack.com/apt/debian/9/amd64/latest stretch main" >> /etc/apt/sources.list.d/saltstack.list | tee $logFile
    apt-get update
    apt-get -y install salt-minion
    numPkgs = `dpkg -l | grep salt | grep ^ii | wc -l`
    if [ $numPkgs -eq 2 ]; then
        echo "Salt installed successfully" >> $logFile
    else
        echo "Salt was not installed" >> $logFile
    fi
fi

# Add minion host to /etc/hosts
#sudo echo "$saltMaster" | tee -a /etc/hosts

# Configure salt minion
#sudo echo -e "+ master: $saltMaster" | tee -a /etc/salt/minion

# Enable and sart salt minion
#sudo systemctl enable salt-minion && sudo systemctl start salt-minion
