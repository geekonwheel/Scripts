#!/bin/bash
#please provide the username

[[ $1 == "" ]] && echo "Bad usage : ./install_docker.sh [user] (works with debian ubuntu and raspbian)" && exit 1

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

update(){
	echo "Doing updates"
	apt update -y && apt upgrade -y
	echo "Updates done"
}

install_componant(){
	echo "Installing basic packages to allow for docker"
	apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	curl -fsSL https://download.docker.com/linux/$OS/gpg | apt-key add -
	echo "Adding docker repos"
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$OS $(lsb_release -cs) stable"
	update
	echo "Installing docker"
	apt-get install -y docker-ce docker-ce-cli containerd.io		
}
add_user(){
	echo "Allowing $1 to use docker"
	/sbin/usermod -aG docker $1
}
compose(){
	echo "installing docker compose"
	release=$( curl https://github.com/docker/compose/releases/latest | cut -d"/" -f 8 | cut -d"\"" -f 1 )
	release=$( expr ${release} )
	curl -L "https://github.com/docker/compose/releases/download/${release}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose 
}
main(){
	OS=$( lsb_release -i | awk '{print $3}' | tr [:upper:] [:lower:] )
	update
	install_componant $OS
	add_user $1
	compose
	echo "Please log in and out to allow the user $1 to run docker"
}
main $1

