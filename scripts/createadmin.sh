#!/bin/bash

# CreateAdmin v5

# Create Quizlet IT
read -r -p 'What is the Quizlet IT password? ' -s PASSWORD

PSUM=$(echo -n ${PASSWORD} | shasum)

if [[ "${PSUM}" != "8821db01a5b6183ae67f18d1b10e11dea4e97144  -" ]]; then
    echo "Incorrect Password.  Exiting."
    exit 1
fi

if [[ $(dscl . list /Users) =~ "qit" ]]; then 
    echo "Quizlet IT already exists.  Skipping creation"
else 
	echo "Creating Quizlet IT account"
	. /etc/rc.common
	dscl . create /Users/qit
	dscl . create /Users/qit RealName "Quizlet IT"
	dscl . create /Users/qit picture "/Volumes/qit/Qsquare.png"
	dscl . passwd /Users/qit ${PASSWORD}
	dscl . create /Users/qit UniqueID 450
	dscl . create /Users/qit PrimaryGroupID 20
	dscl . create /Users/qit UserShell /bin/bash
	dscl . create /Users/qit NFSHomeDirectory /Users/qit
	dscl . append /Groups/admin GroupMembership qit
	cp -R /System/Library/User\ Template/English.lproj /Users/qit
	chown -R qit:staff /Users/qit
	echo "Done creating the IT account"
fi

# enable ARD
echo "Enabling ARD"
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUser
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users qit -access -on -privs -all -restart -agent -menu
echo "Done"