#!/bin/bash

CURRENT_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

echo "#### Preparing Laptop for Quizlet ####"

echo "--- Commandline Tools ---\n"
os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
# string comparison
if [[ "$os" == 10.15 ]]; then
	echo "macOS Catalina"
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
	echo "macOS High Sierra"
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
	echo "Mac OS X 10.13 or earlier"
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
fi

sudo mkdir -p /opt/projects
sudo chown -R $CURRENT_USER /opt/projects
ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
sudo ssh-keyscan -t rsa github.com > ~/.ssh/ssh_known_hosts
echo "##### quizlet-web..."
cd /opt/projects
git clone git@github.com:quizlet/quizlet-web.git quizlet

echo "##### quizlet-puppet..."
git clone git@github.com:quizlet/quizlet-puppet.git


echo "##### quizlet-workstation..."
git clone git@github.com:quizlet/quizlet-workstation.git

chown -R $CURRENT_USER /opt/projects

echo "--- Installing Homebrew ---"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

sudo -u "$CURRENT_USER" /usr/local/bin/brew cask install google-chrome
xattr -rd com.apple.quarantine /Applications/Google\ Chrome.app

sudo -u "$CURRENT_USER" /usr/local/bin/brew cask install 1password
xattr -rd com.apple.quarantine /Applications/1Password\ 7.app

sudo -u "$CURRENT_USER" /usr/local/bin/brew cask install slack
xattr -rd com.apple.quarantine /Applications/Slack.app

sudo -u "$CURRENT_USER" /usr/local/bin/brew cask install tunnelblick
xattr -rd com.apple.quarantine /Applications/Tunnelblick.app

sudo -u "$CURRENT_USER" /usr/local/bin/brew cask install visual-studio-code
xattr -rd com.apple.quarantine /Applications/Visual\ Studio\ Code.app
