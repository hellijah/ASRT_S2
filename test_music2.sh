#!/bin/bash

# Test lecture directe youtube
# sudo apt-get install youtube-dl mpv
# youtube-dl -q -o- "https://www.youtube.com/watch?v=9jHDPhsrCnY" | mpv -
# ou mpv --no-video $(youtube-dl -g -f bestaudio "https://www.youtube.com/watch?v=9jHDPhsrCnY")

# lien cuisinella https://www.youtube.com/watch?v=9jHDPhsrCnY


#sudo apt-get install mpg123    # Pour Debian/Ubuntu

if ! command -v mpg123 &> /dev/null; then
    read -p "$yellow Le programme 'mpg123' n'est pas installé. Souhaitez-vous l'installer ? (oui/non) : $clear " install_mpg123
    if [ "$install_mpg123" = "oui" ]; then

        # Installation de mpg123
        apt-get update
        apt-get install -y mpg123
    else
        echo -e "$red Installation de 'mpg123' annulée. $clear"
        exit 1
    fi
fi

# mpg123 /home/thierry/Téléchargements/Cuisinella_Jingle.mp3


# fonctionne si fichier MP3 dans le même dossier que le script
mpg123 ./Cuisinella_Jingle.mp3 &> /dev/null




