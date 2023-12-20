#!/bin/bash

#sudo apt-get install sox    # Pour Debian/Ubuntu

if ! command -v sox &> /dev/null; then
    read -p "$yellow Le programme 'sox' n'est pas installé. Souhaitez-vous l'installer ? (oui/non) : $clear " install_sox
    if [ "$install_sox" = "oui" ]; then
        # Installation de dialog
        apt-get update
        apt-get install -y sox
    else
        echo -e "$red Installation de 'sox' annulée. $clear"
        exit 1
    fi
fi

# Utilisation de SoX pour générer un son
#play -n synth <duration> sin <frequency>

play -n synth 0.5 sin 440 && sleep 1 && play -n synth 1 sin 440 && sleep 1 && play -n synth 1 sin 440 && sleep 0.5

# sudo apt-get install mpg123
# mpg123 Cuisinella_Jingle.mp3 