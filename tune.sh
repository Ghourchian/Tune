#!/bin/bash
#adduser
sudo chpasswd << 'END' mehrdad:Mehrdad@123 END

if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -s -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system."
	exit 2
fi

echo '$username ALL=(ALL) NOPASSWD:ALL ' >> /etc/sudoers



# Variables

file="$1"
param[1]="PermitRootLogin "
param[2]="PubkeyAuthentication"
param[3]="AuthorizedKeysFile"
param[4]="PasswordAuthentication"
param[5]="Port"


# Functions
usage(){
  cat << EOF
    usage: $0 ARG1
    ARG1 Name of the sshd_config file to edit.
    In case ARG1 is empty, /etc/ssh/sshd_config will be used as default.

    Description:
    This script sets certain parameters in /etc/ssh/sshd_config.
    It's not production ready and only used for training purposes.

    What should it do?
    * Check whether a /etc/ssh/sshd_config file exists
    * Create a backup of this file
    * Edit the file to set certain parameters
EOF
}

backup_sshd_config(){
  if [ -f ${file} ]
  then
    /usr/bin/cp ${file} ${file}.1
  else
    /usr/bin/echo "File ${file} not found."
    exit 1
  fi
}

edit_sshd_config(){
  for PARAM in ${param[@]}
  do
    /usr/bin/sed -i '/^'"${PARAM}"'/d' ${file}
    /usr/bin/echo "All lines beginning with '${PARAM}' were deleted from ${file}."
  done
  /usr/bin/echo "${param[1]} no" >> ${file}
  /usr/bin/echo "'${param[1]} no' was added to ${file}."
  /usr/bin/echo "${param[2]} yes" >> ${file}
  /usr/bin/echo "'${param[2]} yes' was added to ${file}."
  #/usr/bin/echo "${param[4]} .ssh/authorized_keys" >> ${file}
  #/usr/bin/echo "'${param[4]} .ssh/authorized_keys' was added to 
${file}."
  /usr/bin/echo "${param[4]} yes" >> ${file}
  /usr/bin/echo "'${param[4]} yes' was added to ${file}."

  /usr/bin/echo "${param[5]} 62355" >> ${file}
  /usr/bin/echo "'${param[5]} no' was added to ${file}"
  /usr/bin/echo "AllowUsers $username" >> ${file}
  /usr/bin/echo " user added to ${file}"
  
}

reload_sshd(){
  /usr/bin/systemctl reload sshd.service
  /usr/bin/echo "Run '/usr/bin/systemctl reload sshd.service'...OK"
}

# main
while getopts .h. OPTION
do
  case $OPTION in
    h)
    usage
    exit;;
    ?)
    usage
    exit;;
  esac
done

if [ -z "${file}" ]
then

file="/etc/ssh/sshd_config"
fi
backup_sshd_config
edit_sshd_config
reload_sshd
