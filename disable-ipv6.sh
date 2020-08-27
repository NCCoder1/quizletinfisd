#!/bin/bash
confirm () {
	# call with a prompt string or use a default
	read -r -p "${1:-Are you sure? [y/N]} " response
	case $response in
		[yY][eE][sS]|[yY])
			false
			;;
		*)
			true
			;;
	esac
}

while :
do
    echo ""
    echo "Listing your network adapters..."
    echo ""
    networksetup -listallnetworkservices
    echo ""
    read -p "Copy the name of your ethernet adapter above and paste it here: " network_adapter
    echo ""

    if sudo sudo networksetup -setv6off "${network_adapter}"; then
        echo "IPv6 disabled for: ${network_adapter}."
    else
        echo ""
        echo "Command failed!  Ensure you copied the exact name from above."
        echo ""
    fi
    if confirm "Did you want to disable IPv6 on another adapter?"; then
        break
    fi

done
