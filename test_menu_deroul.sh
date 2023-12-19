#!/bin/bash

# Ajout des variables de couleur
red='\033[0;31m'
yellow='\033[1;31m'
green='\033[1;32m'
# Couleur standard
clear='\033[0m'

# Fonction pour configurer le nom d'hôte
configure_hostname() {
    read -p "spécifier un nouveau nom d'hôte pour la machine. : " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo "Mon nouveau nom est: $new_hostname."
    
}

# Fonction pour créer un nouvel utilisateur
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
            		echo "User '$username' a était ajouté '$group_name'."
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

# Fonction pour l'installation de logiciels
install_software() {
   # read -p "spécifier les noms des logiciels à installer : " software_list
   # sudo apt-get update &>/dev/null
   # sudo apt-get install -y $software_list &>/dev/null 
   # echo "logiciels installer: $software_list"
   read -p "spécifier les noms des logiciels à installer : " software_list

# Check if the software list is not empty
   if [ -n "$software_list" ]; then
        sudo apt update  &>/dev/null  # c'est toujours bien de verifier que le repertory est bien ajour, donc on update toujours avant d'installer n'importe quoi.
        sudo apt install -y $software_list  # Installation de l'apt du logiciel à renseigner 
        if [ $? -eq 0 ]; then #si la sorti $?=0 alors l'instalation a bien eté faite 
                echo "le logiciel: $software_list, a bien été installé!"
        else
                echo "Il semble y avoir un problème avec l'installation . "# si $? !=0 alors il y a eu un probleme.    
        fi
   else
        echo "Le logiciel $software_list n'existe pas ." 
   fi

 } 

# Fonction pour la configuration réseau
network_configuration() {
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


options=("Configuration du Nom d'Hôte" "Création d'un Nouvel Utilisateur" "Installation de Logiciels" "Configuration Réseau")

# Fonction pour afficher le menu
afficher_menu() {
    clear
    echo "Sélectionnez une option avec les touches fléchées et appuyez sur Entrée pour choisir."
    echo "Appuyez sur 'q' pour quitter."
    echo ""
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo "-> ${options[i]}"
        else
            echo "   ${options[i]}"
        fi
    done
}

selected=0



# Boucle pour afficher le menu et traiter les choix
while true; do
    afficher_menu
    read -rsn1 key  # Lecture d'un seul caractère pour détecter les touches
    case $key in
        $'\x1B')  # Touche ESC pour quitter
            read -rsn2 -t 0.1 key
            if [ "$key" == "[A" ] && [ $selected -gt 0 ]; then
                ((selected--))
            elif [ "$key" == "[B" ] && [ $selected -lt $((${#options[@]}-1)) ]; then
                ((selected++))
            fi ;;
        'q')  # Touche "q" pour quitter
            echo "Au revoir !"
            break ;;
        $'\n')  # Touche Entrée pour sélectionner
            echo "Vous avez choisi : ${options[selected]}"
            case $selected in
                0) configure_hostname;;
                1) create_new_user;;
                2) install_software;;
                3) network_configuration;;
            esac
            read -rsp $'Appuyez sur n\'importe quelle touche pour continuer...\n' -n1 key ;;
    esac
done


#il reste a integrer chaque fonction , ameliorer le visuelle avec une coloration ,
#et rajouter quelques fonctionnalitées pour etre encore plus brillant 
#? un menu au lancement pour selectionner la langue ? 
#rajouter le mot de passe robuste ainsi que la necessité de taper son code pour effectuer les modifications 
#un retour au debut du script en appuyant sur la touche X
#et effectuer des tests sur des machines differentes ( si possible sur celle de adil puisqu il testera sur la sienne)