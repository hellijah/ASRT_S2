#!/bin/bash

# Ajout des variables de couleur
red='\e[31m'
yellow='\e[33m'
green='\e[32m'
green_background='\e[42m'
# Couleur standard
clear='\e[0m'


# Function to configure the host name
configure_hostname() {
    read -p "spécifier un nouveau nom d'hôte pour la machine. : " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo -e "$green Mon nouveau nom est: $new_hostname. $clear "
    
}

# Function to create a new user
create_new_user() {
    while true; do
        read -p "Entrer le nom d'utilisateur : " username
        read -p "Entrer le mot de passe pour: $username: " password
        # test password fort
        
        # confirmation password
        read -p "Entrer le password pour confirmer" password2
        if [ "$password" = "$password2"]; then
            break
        else
    done


    if grep -q "$username:" /etc/passwd; then
	    echo -e "$yellow l'utilisateur existe déjà $clear "
	    
	    
    else
    	sudo useradd -m -s /bin/bash "$username" &>/dev/null 
    	echo "$username:$password" | sudo chpasswd
    	echo -e "$green User $username créé. $clear"
    	read -p "voulez vous ajouter $username dans un groupe ? (o/n): " add_user_to_group

# if echo "Bonjour le monde" | grep -i "$motif";
    	if [ "$add_user_to_group" = "o" ]; then
    		read -p "Entrer le groupe : " group_name

    	if grep -q "$group_name:" /etc/group; then
        	read -p "$yellow Le groupe '$group_name' existe. Voulez-vous ajouter l’utilisateur à ce groupe? (o/n): $clear " add_to_existing_group

        	if [ "$add_to_existing_group" = "o" ]; then
            		echo -e "¢a marche, on va ajouter $username, dans $group_name "
            		sudo adduser "$username" "$group_name"
            		echo -e "$green User '$username' est maintenant dans le groupe'$group_name'. $clear "
        	else
            		echo -e "$red On arrête. $clear "
            		exit 1
		fi
    	else
        	read -p "$yellow le groupe '$group_name' n’existe pas. Voulez-vous créer ce groupe? (o/n): $clear" create_group

        	if [ "$create_group" = "o" ]; then
            		sudo groupadd "$group_name"
            		echo "Groupe '$group_name'créé ."
          
            		sudo adduser "$username" "$group_name"
            		echo -e "$green User '$username' a été ajouté '$group_name'. $clear "
        	else
            		echo -e "$red le groupe n'a pas été créé. $clear"
            		exit 1
        	fi
    	fi
 	elif [ "$add_user_to_group" = "n" ]; then
    		echo -e "$green Pas de probleme. $clear "
	else
    		echo -e "$yellow Choix non valide. Veuillez entrer 'o' ou 'n'. $clear"
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
                echo -e "$green le logiciel: $software_list, a bien été installé ! $clear"
        else
                echo -e "$red Il semble y avoir un problème avec l'installation . $clear " # si $? !=0 alors il y a eu un probleme.    
        fi
   else
        echo -e "$red Le logiciel $software_list n'existe pas . $clear" 
   fi

 } 

# Function for network configuration
network_configuration() {
   
    # Vérification de la présence de dialog et installation le cas échéant
if ! command -v dialog &> /dev/null; then
    read -p "$yellow Le programme 'dialog' n'est pas installé. Souhaitez-vous l'installer ? (o/n) : $clear " install_dialog
    if [ "$install_dialog" = "o" ]; then
        # Installation de dialog
        apt-get update
        apt-get install -y dialog
    else
        echo -e "$red Installation de 'dialog' annulée. $clear"
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
        echo -e "$red Adresse IP invalide. Veuillez entrer une adresse IP valide. $clear"
        continue
    else
        echo -e "$green Adresse IP valide : $adresse_ip $clear"
    fi
    if ! [[ $masque_sous_reseau =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "$red Masque de sous-réseau invalide. Veuillez entrer un masque valide (ex: 255.255.255.0). $clear "
        continue
    else
        echo -e "$green Masque de sous-réseau valide : $masque_sous_reseau $clear"
    fi
    # Configuration du réseau avec les informations fournies, Changer "eth0" selon votre interface réseau
    sudo ip addr add $adresse_ip/$masque_sous_reseau dev eth0 || { echo -e "$red Erreur lors de la configuration de l'adresse IP. $clear"; break; }
    sudo ip route add default via $passerelle || { echo -e "$red Erreur lors de l'ajout de la passerelle. $clear"; break; }
    echo "nameserver $dns_primaire" | sudo tee /etc/resolv.conf > /dev/null || { echo -e "$red Erreur lors de la configuration du DNS primaire. $clear"; break; }
    echo "nameserver $dns_secondaire" | sudo tee -a /etc/resolv.conf > /dev/null || { echo -e "$red Erreur lors de la configuration du DNS secondaire. $clear"; break; }
    # Affichage des informations renseignées
    echo -e "$green_background Informations renseignées : $clear "
    echo "Adresse IP : $adresse_ip"
    echo "Masque de sous-réseau : $masque_sous_reseau"
    echo "Passerelle par défaut : $passerelle"
    echo "Serveur DNS primaire : $dns_primaire"
    echo "Serveur DNS secondaire : $dns_secondaire"
    echo "Les paramètres réseau ont été configurés avec succès."
    read -p "Voulez-vous configurer un autre réseau ? (o/n) " reponse
    if [ "$reponse" != "o" ]; then
        echo "Au revoir !"
        break
    fi
done
}

while true; do
    clear
    echo -e "$green_background===== Configuration Menu =====$clear"
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
