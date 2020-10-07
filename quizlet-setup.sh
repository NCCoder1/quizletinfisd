#!/bin/bash

CURRENT_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
echo ""
echo " ######################################"
echo "####                                ####"
echo "####    Quizlet Contractor Setup    ####"
echo "####                                ####"
echo " ######################################"

sleep 3
echo ""
echo ""

# Commandline Tools
os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
if [[ "$os" == 10.15 ]]; then
	echo "macOS Catalina confirmed"
    if softwareupdate --history | grep --silent "Command Line Tools.*"; then
		echo 'Command-line tools already installed.'
	else
		echo ""
		echo '##### Installing Command-line tools...'
    	in_progress=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    	touch ${in_progress}
    	product=$(softwareupdate -l | grep -B 1 -E 'Command Line Tools' | awk -F'*' '/^ *\\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)
    	softwareupdate --verbose --install "${product}" || echo 'Installation failed.' 1>&2 && rm ${in_progress} && echo 'Command-line tools installed.'
	fi

elif [[ "$os" == 10.14 ]]; then
	echo "macOS Mojave confirmed"
    if softwareupdate --history | grep --silent "Command Line Tools.*${os}"; then
		echo 'Command-line tools already installed.'
	else
		echo ""
		echo '##### Installing Command-line tools...'
    	in_progress=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    	touch ${in_progress}
    	product=$(softwareupdate --list | awk "/\* Command Line.*${os}/ { sub(/^   \* /, \"\"); print }")
    	softwareupdate --verbose --install "${product}" || echo 'Installation failed.' 1>&2 && rm ${in_progress} && echo 'Command-line tools installed.'
	fi
else
	echo "You are running an unsupported version of MacOS.  Please use the latest official version of MacOS to continue."
	exit 1
fi

# Homebrew
if [[ $(command -v brew) == "" ]]; then
    echo "##### Installing Hombrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "##### Updating Homebrew..."
    brew update
fi

echo "##### Installing default applications..."
/usr/local/bin/brew cask install google-chrome
/usr/local/bin/brew cask install firefox
/usr/local/bin/brew cask install 1password
/usr/local/bin/brew cask install slackit
/usr/local/bin/brew cask install atom
/usr/local/bin/brew cask install visual-studio-code

ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

# Check if SSH is authorized to Github
if ssh -q git@github.com; [ $? -eq 255 ]; then
	echo "We were not able to successfully connect to Github.  Please fix and rerun script."
	exit 1
else
	# successfully authenticated
	if [ ! -d "/opt/projects" ]; then
		echo "Creating /opt/projects"
		sudo mkdir -p /opt/projects
		sudo chown -R $CURRENT_USER /opt/projects
	fi

	if [ -d "/opt/projects/quizlet-workstation" ]; then
		echo ""
		echo "##### Updating quizlet-workstation..."
		cd /opt/projects/quizlet-workstation
		git fetch && git reset --hard origin/master && git checkout master && git pull origin master && git submodule sync && git submodule update && git clean -ffd
	else
		echo ""
		echo "##### Downloading quizlet-workstation..."
		cd /opt/projects/
		git clone git@github.com:quizlet/quizlet-workstation.git
	fi
   chown -R $CURRENT_USER /opt/projects
fi

echo "Please follow the next steps in our Engineering setup guide in Qonfluence."
