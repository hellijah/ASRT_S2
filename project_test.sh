#!/bin/bash

# Ajout des variables de couleur
red='\033[0;31m'
yellow='\033[1;31m'
green='\033[1;32m'
# Couleur standard
clear='\033[0m'


# Function to configure the host name
configure_hostname() {
    read -p "spécifier un nouveau nom d'hôte pour la machine. : " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo "Mon nouveau nom est: $new_hostname."
    
}

# Function to create a new user
create_new_user() {
    read -p "Entrer le nom d'utilisateur : " username
    read -p "Entrer le mot de passe pour: $username: " password
    if grep -q "$username:" /etc/passwd; then
	    echo "l'utilisateur existe déjà"
	    
	    
    else
    	sudo useradd -m -s /bin/bash "$username" &>/dev/null 
    	echo "$username:$password" | sudo chpasswd
    	echo "User $username créé."
    	read -p "voulez vous ajouter $username dans un groupe ? (yes/no): " add_user_to_group

    	if [ "$add_user_to_group" = "yes" ]; then
    		read -p "Entrer le groupe : " group_name

    	if grep -q "$group_name:" /etc/group; then
        	read -p "Le groupe '$group_name' existe. Voulez-vous ajouter l’utilisateur à ce groupe? (yes/no): " add_to_existing_group

        	if [ "$add_to_existing_group" = "yes" ]; then
            		echo "¢a marche, on va ajouter $username, dans $group_name "
            		sudo adduser "$username" "$group_name"
            		echo "User '$username' est maintenant dans le groupe'$group_name'."
        	else
            		echo "On arrête."
            		exit 1
		fi
    	else
        	read -p " le groupe '$group_name' n’existe pas. Voulez-vous créer ce groupe? (yes/no): " create_group

        	if [ "$create_group" = "yes" ]; then
            		sudo groupadd "$group_name"
            		echo "Groupe '$group_name'créé ."
          
            		sudo adduser "$username" "$group_name"
            		echo "User '$username' a été ajouté '$group_name'."
        	else
            		echo "le groupe n'a pas été créé."
            		exit 1
        	fi
    	fi
 	elif [ "$add_user_to_group" = "no" ]; then
    		echo "Pas de probleme. "
	else
    		echo "Choix non valide. Veuillez entrer 'yes' or 'no'."
    		exit 1
	fi

fi



}

# Function to install software
install_software() {
   # read -p "spécifier les noms des logiciels à installer : " software_list
   # sudo apt-get update &>/dev/null
   # sudo apt-get install -y $software_list &>/dev/null 
   # echo "logiciels installer: $software_list"
   read -p "spécifier les noms des logiciels à installer : " software_list

# Check if the software list is not empty
   if [ -n "$software_list" ]; then
        sudo apt update  &>/dev/null  # c'est toujours bien de verifier que le repertory est bien à jour, donc on update toujours avant d'installer n'importe quoi.
        sudo apt install -y $software_list  # Installation de l'apt du logiciel renseigné 
        if [ $? -eq 0 ]; then #si la sorti $?=0 alors l'installation a bien été faite 
                echo "le logiciel: $software_list, a bien été installé !"
        else
                echo "Il semble y avoir un problème avec l'installation . "# si $? !=0 alors il y a eu un probleme.    
        fi
   else
        echo "Le logiciel $software_list n'existe pas ." 
   fi

 } 

# Function for network configuration
network_configuration() {
   
    # Vérification de la présence de dialog et installation le cas échéant
if ! command -v dialog &> /dev/null; then
    read -p "Le programme 'dialog' n'est pas installé. Souhaitez-vous l'installer ? (oui/non) : " install_dialog
    if [ "$install_dialog" = "oui" ]; then
        # Installation de dialog
        apt-get update
        apt-get install -y dialog
    else
        echo "Installation de 'dialog' annulée."
        exit 1
    fi
fi

while true; do
    read -p "Entrez l'adresse IP : " adresse_ip
    read -p "Entrez le masque de sous-réseau : " masque_sous_reseau
    read -p "Entrez la passerelle par défaut : " passerelle
    read -p "Entrez le serveur DNS primaire : " dns_primaire
    read -p "Entrez le serveur DNS secondaire : " dns_secondaire
    # Vérification de la validité de l'adresse IP et du masque de sous-réseau
    if ! [[ $adresse_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Adresse IP invalide. Veuillez entrer une adresse IP valide."
        continue
    else
        echo "Adresse IP valide : $adresse_ip"
    fi
    if ! [[ $masque_sous_reseau =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Masque de sous-réseau invalide. Veuillez entrer un masque valide (ex: 255.255.255.0)."
        continue
    else
        echo "Masque de sous-réseau valide : $masque_sous_reseau"
    fi
    # Configuration du réseau avec les informations fournies, Changer "eth0" selon votre interface réseau
    sudo ip addr add $adresse_ip/$masque_sous_reseau dev eth0 || { echo "Erreur lors de la configuration de l'adresse IP."; break; }
    sudo ip route add default via $passerelle || { echo "Erreur lors de l'ajout de la passerelle."; break; }
    echo "nameserver $dns_primaire" | sudo tee /etc/resolv.conf > /dev/null || { echo "Erreur lors de la configuration du DNS primaire."; break; }
    echo "nameserver $dns_secondaire" | sudo tee -a /etc/resolv.conf > /dev/null || { echo "Erreur lors de la configuration du DNS secondaire."; break; }
    # Affichage des informations renseignées
    echo "Informations renseignées :"
    echo "Adresse IP : $adresse_ip"
    echo "Masque de sous-réseau : $masque_sous_reseau"
    echo "Passerelle par défaut : $passerelle"
    echo "Serveur DNS primaire : $dns_primaire"
    echo "Serveur DNS secondaire : $dns_secondaire"
    echo "Les paramètres réseau ont été configurés avec succès."
    read -p "Voulez-vous configurer un autre réseau ? (O/N) " reponse
    if [ "$reponse" != "O" ]; then
        echo "Au revoir !"
        break
    fi
done
}

while true; do
    echo "===== Configuration Menu ====="
    echo "1.Configuration du Nom d'Hôte "
    echo "2.Création d'un Nouvel Utilisateur "
    echo "3.Installation de logiciels "
    echo "4.Configuration réseau  "
    echo "5.Quitter "
   
    read -p "Entrer votre choix (1-5): " choice

    case $choice in
        1) configure_hostname ;;
        2) create_new_user ;;
        3) install_software ;;
        4) network_configuration ;;
        5) echo "au revoir!"; exit ;;
        *) echo "Choix incorrect , effectuez un choix entre 1 & 5." ;;
    esac
done
