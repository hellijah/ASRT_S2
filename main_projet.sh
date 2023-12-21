#!/bin/bash

# Ajout des variables de couleur
red='\e[31m'
yellow='\e[33m'
green='\e[32m'
green_background='\e[42m'
blue_background='\e[44m'
# Couleur standard
clear='\e[0m'


# Function to configure the host name
configure_hostname() {
    read -p "spécifier un nouveau nom d'hôte pour la machine. : " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo -e "$green Mon nouveau nom est: $new_hostname. $clear "
    
}

#!/bin/bash

# Fonction pour tester la force du mot de passe
check_password_strength() {
    password=$1
    length=${#password}
    has_lowercase=$(echo "$password" | grep -q [a-z] && echo "true" || echo "false")
    has_uppercase=$(echo "$password" | grep -q [A-Z] && echo "true" || echo "false")
    has_digit=$(echo "$password" | grep -q [0-9] && echo "true" || echo "false")
    has_special=$(echo "$password" | grep -q '[^A-Za-z0-9]' && echo "true" || echo "false")

    # Évaluer différentes caractéristiques du mot de passe
    if [ "$length" -ge 8 ] && [ "$has_lowercase" = "true" ] && [ "$has_uppercase" = "true" ] && [ "$has_digit" = "true" ] && [ "$has_special" = "true" ]; then
        echo "Le mot de passe est fort."
        exit 0
    else
        echo "Le mot de passe est faible. Assurez-vous qu'il a au moins 8 caractères, des lettres majuscules, des lettres minuscules, des chiffres et des caractères spéciaux."
        exit 1
    fi
}

# Function to create a new user
create_new_user() {
    while true; do

        read -p "Entrer le nom d'utilisateur : " username
        # test password fort
        while true; do
            # Demander à l'utilisateur d'entrer le mot de passe à tester
            read -s -p "Entrez le mot de passe à tester : " password
            # echo

            # Tester la force du mot de passe
            check_password_strength "$password"

            if [ "$?" -eq 0 ]; then
                break
            fi

        done

        # confirmation password
        read -s -p "Entrer le password à nouveau pour confirmer : " password2
        if [ "$password" = "$password2" ]; then
            echo -e "$green Password Validé $clear"
            break
        else
            echo -e "$red le Password ne correspond $clear "
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
        	echo -e "$yellow Le groupe '$group_name' existe. Voulez-vous ajouter l’utilisateur à ce groupe? (o/n): 
            read $clear " add_to_existing_group

        	if [ "$add_to_existing_group" = "o" ]; then
            		echo -e "¢a marche, on va ajouter $username, dans $group_name "
            		sudo adduser "$username" "$group_name"
            		echo -e "$green User '$username' est maintenant dans le groupe'$group_name'. $clear "
        	else
            		echo -e "$red On arrête. $clear "
            		exit 1
		fi
    	else
        	echo -e "$yellow le groupe '$group_name' n’existe pas. Voulez-vous créer ce groupe? (o/n): $clear" 
            read create_group

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
    echo -e "$yellow Le programme 'dialog' n'est pas installé. Souhaitez-vous l'installer ? (o/n) : $clear " 
    read install_dialog
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

# Function for easter egg Jingle
jingle_cuisinella() {
if ! command -v mpg123 &> /dev/null; then
    echo -e "$yellow Le programme 'mpg123' n'est pas installé. Souhaitez-vous l'installer ? (o/n) : $clear " 
    read install_mpg123
    if [ "$install_mpg123" = "o" ]; then

        # Installation de mpg123
        apt-get update
        apt-get install -y mpg123
    else
        echo -e "$red Installation de 'mpg123' annulée. $clear"
        exit 1
    fi
fi

# fonctionne si fichier MP3 dans le même dossier que le script
mpg123 ./Cuisinella_Jingle.mp3 &> /dev/null

}

# while true; do
    # clear
    # echo -e "$green_background===== Configuration Menu =====$clear"
    # echo "1.Configuration du Nom d'Hôte "
    # echo "2.Création d'un Nouvel Utilisateur "
    # echo "3.Installation de logiciels "
    # echo "4.Configuration réseau  "
    # echo "5.Quitter "
   
    # read -p "Entrer votre choix (1-5): " choice

    # case $choice in
    #     1) configure_hostname ;;
    #     2) create_new_user ;;
    #     3) install_software ;;
    #     4) network_configuration ;;
    #     5) echo "au revoir!"; exit ;;
    #     *) echo "Choix incorrect , effectuez un choix entre 1 & 5." ;;
    # esac
# done

# Function for Audio_guide
Audio_guide() {
if ! command -v mpg123 &> /dev/null; then
    echo -e "$yellow Le programme 'mpg123' n'est pas installé. Souhaitez-vous l'installer ? (o/n) : $clear " 
    read install_mpg123
    if [ "$install_mpg123" = "o" ]; then

        # Installation de mpg123
        apt-get update
        apt-get install -y mpg123
    else
        echo -e "$red Installation de 'mpg123' annulée. $clear"
        exit 1
    fi
fi

# fonctionne si fichier MP3 dans le même dossier que le script
mpg123 ./guide_utilisateur.mp3 &> /dev/null

}


options=("Configuration du Nom d'Hôte" "Création d'un Nouvel Utilisateur" "Installation de Logiciels" "Configuration Réseau" "Audio guide utilisateur" "quitter")

# Fonction pour afficher le menu
afficher_menu() {
    clear
    echo "Sélectionnez une option avec les touches fléchées et appuyez sur entrée pour choisir."
    # echo "Appuyez sur 'q' pour quitter."
    echo ""
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "-> $blue_background ${options[i]} $clear"
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
        #$'\n')  # Touche Entrée pour sélectionner
        "") # touche entrée pour valider
            echo "Vous avez choisi : ${options[selected]}"
            case $selected in
                0) configure_hostname;;
                1) create_new_user;;
                2) install_software;;
                3) network_configuration;;
                4) Audio_guide;; 
                5) echo "au revoir!"; exit ;;

            esac
            read -rsp "Appuyez sur n'importe quelle touche pour continuer..." -n1 key ;;
        'e') # touche e pour jingle
            jingle_cuisinella;;

        #'*') # toutes autres touche donne un choix invalide


    esac
done
