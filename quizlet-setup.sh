#!/bin/bash

CURRENT_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

echo "#### Preparing Laptop for Quizlet ####"

echo "--- Commandline Tools ---\n"
os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
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
fi # Commandline Tools complete

sudo mkdir -p /opt/projects
sudo chown -R $CURRENT_USER /opt/projects

if ! grep github.com ~/.ssh/known_hosts > /dev/null
then
     echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> ~/.ssh/known_hosts
fi

# Check if SSH is authorized to Github
if ssh -q git@github.com; [ $? -eq 255 ]; then
   echo "We were not able to successfully connect to Github.  Please fix and rerun script."
else
   # successfully authenticated
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
fi
