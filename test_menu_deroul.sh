#!/bin/bash

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

# Fonction pour configurer le nom d'hôte
configure_hostname() {
    # À compléter
}

# Fonction pour créer un nouvel utilisateur
create_new_user() {
    # À compléter
}

# Fonction pour l'installation de logiciels
install_software() {
    # À compléter
}

# Fonction pour la configuration réseau
network_configuration() {
    # À compléter
}

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