#!/bin/bash
#This script performs various offboarding tasks when a user leaves the company.

gam="$HOME/bin/gam/gam"

# Enter user to deprovision
echo "Enter username you wish to deprovision: "
read username

#Confirm user name before deprovisioning
read -r -p "Do you want to deprovision $username ? [y/n] " response
if [[ $response =~ [nN] ]]
  then
		echo "Exiting"
		exit
fi

#Should user's calendar be wiped? If so, it will be wiped later
echo "Do you want to Wipe $username's calendar? [y/n] "
read cal_response

#Starting deprovision
echo ""
echo "============================================"
echo "Deprovisioning " $username"..."

# Removing all mobile devices connected
echo "Gathering mobile devices for $username"
IFS=$'\n'
mobile_devices=($($gam print mobile query $username | grep -v resourceId | awk -F"," '{print $1}'))
unset IFS
	for mobileid in ${mobile_devices[@]}
		do
			$gam update mobile $mobileid action account_wipe && echo "Removing $mobileid from $username"
	done | tee -a /tmp/$username.log

# Changing user's password to random
echo "Changing "$username"'s' password to something random"
$gam update user $username password random | tee -a /tmp/$username.log

# Removing all App-Specific account passwords, deleting MFA Recovery Codes,
# deleting all OAuth tokens
echo "Checking and Removing all of "$username"'s Application Specific Passwords, 2SV Recovery Codes, and all OAuth tokens"
$gam user $username deprovision | tee -a /tmp/$username.log

# Removing user from all Groups
$gam user $username delete group

# Forcing change password on next sign-in and then disabling immediately.
# Speculation that this will sign user out within 5 minutes and not allow
# user to send messages without reauthentication
echo "Setting force change password on next logon and then disabling immediately to expire current session"
$gam update user $username changepassword on | tee -a /tmp/$username.log
sleep 2
$gam update user $username changepassword off | tee -a /tmp/$username.log

# Generating new set of MFA recovery codes for the user. Only used if Admin needed to log in as the user once suspended
echo "Generating new 2SV Recovery Codes for $username"
#Supressing the screen output
{
$gam user $username update backupcodes | tee -a /tmp/$username.log
} &> /dev/null

# Removing all of user's calendar events if previously selected
if [[ $cal_response =~ [yY] ]]
then
		echo "Deleting all of "$username"'s calendar events"
		$gam calendar $username wipe | tee -a /tmp/$username.log
else
		echo "Not wiping calendar" | tee -a /tmp/$username.log
fi

# Suspending user
#echo "Setting $username to suspended" | tee -a /tmp/$username.log
#$gam update user $username suspended on | tee -a /tmp/$username.log
#echo "Account $username suspendeded" | tee -a /tmp/$username.log

#Set forward?
echo "Did you want their email forwarded? "
read emailforward
if [[ $emailforward =~ [yY] ]]
then
		echo "What account should email be forwarded to? "
		read emailforward
		echo "Forwarding "$username"'s email"
		$gam gam user $username add forwardingaddress emailforward | tee -a /tmp/$username.log
else
		echo "Not forwarding email" | tee -a /tmp/$username.log
fi

#Transfer docs to another employee
echo "Email address to receive Google Drive files: "
read drivetransfer

echo "Transfering Google Drive to $drivetransfer"
$gam create datatransfer $username gdrive $drivetransfer privacy_level shared,private
echo "Drive transfer initiated" | tee -a /tmp/$username.log

#Moving user to offboarding OU
echo "Moving $username to the Offboarding OU"
$gam update org Offboarding add users $username

#hiding user from directory
echo "Hiding $username from the GAL"
$gam update user $username gal off

echo "Offboard complete for $username"
echo "============================================""