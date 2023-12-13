#!/bin/bash

# Function to configure the host name
configure_hostname() {
    read -p "spécifier un nouveau nom d'hôte pour la machine. : " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo "Mon nouveaux nom c'est: $new_hostname."
    
}

# Function to create a new user
create_new_user() {
    read -p "Enter le noms d'utilisateur : " username
    read -p "Enter le mot de passe pour: $username: " password
    if grep -q "$username:" /etc/passwd; then
	    echo "l'utilisateur existe deja"
	    
	    
    else
    	sudo useradd -m -s /bin/bash "$username" &>/dev/null 
    	echo "$username:$password" | sudo chpasswd
    	echo "User $username créé."
    	read -p "voulez vous ajouter $username dans un  group? (yes/no): " add_user_to_group

    	if [ "$add_user_to_group" = "yes" ]; then
    		read -p "Enter le groupe : " group_name

    	if grep -q "$group_name:" /etc/group; then
        	read -p "Le group '$group_name' existe. Voulez-vous ajouter l’utilisateur à ce groupe? (yes/no): " add_to_existing_group

        	if [ "$add_to_existing_group" = "yes" ]; then
            		echo "¢a marche, on va ajouter $username, dans $group_name "
            		sudo adduser "$username" "$group_name"
            		echo "User '$username' est mantenat dans le groupe'$group_name'."
        	else
            		echo "On arrete."
            		exit 1
		fi
    	else
        	read -p " le groupe '$group_name' n’existe pas. Voulez-vous créer ce groupe? (yes/no): " create_group

        	if [ "$create_group" = "yes" ]; then
            		sudo groupadd "$group_name"
            		echo "Groupe '$group_name'créé ."
          
            		sudo adduser "$username" "$group_name"
            		echo "User '$username' a était ajouté '$group_name'."
        	else
            		echo "le roupe n'a pas était créé. BYE."
            		exit 1
        	fi
    	fi
 	elif [ "$add_user_to_group" = "no" ]; then
    		echo "Pas de probleme, ADIOS "
	else
    		echo "Choix non valide. Veuillez entrer 'yes' or 'no'."
    		exit 1
	fi

fi



}

# Function to install software
install_software() {
    read -p "spécifier les noms des logiciels à installer : " software_list
    sudo apt-get update
    sudo apt-get install -y $software_list 
    echo "logiciels installer: $software_list"
}

# Function for network configuration
network_configuration() {
    echo "vous avez choisi l'option Configuration Réseau"
    notify-send Atention "La configuration réseau n’est pas implémentée dans cette démo ."
}

while true; do
    echo "===== Configuration Menu ====="
    echo "1.Configuration du Nom d'Hôte "
    echo "2.Création d'un Nouvel Utilisateur "
    echo "3.Installation de logiciels "
    echo "4.Configuration réseau  "
    echo "5.Quitter "
   
    read -p "Enter your choice (1-5): " choice

    case $choice in
        1) configure_hostname ;;
        2) create_new_user ;;
        3) install_software ;;
        4) network_configuration ;;
        5) echo "ADIOS!"; exit ;;
        *) echo "Invalid choice. Please enter a number between 1 and 5." ;;
    esac
done
