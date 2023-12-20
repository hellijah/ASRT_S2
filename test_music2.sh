#!/bin/bash



#sudo apt-get install mpg123    # Pour Debian/Ubuntu


if ! command -v mpg123 &> /dev/null; then

    read -p "$yellow Le programme 'mpg123' n'est pas installé. Souhaitez-vous l'installer ? (oui/non) : $clear " install_mpg123

    if [ "$install_mpg123" = "oui" ]; then

        # Installation de dialog

        apt-get update

        apt-get install -y mpg123

    else

        echo -e "$red Installation de 'mpg123' annulée. $clear"

        exit 1

    fi

fi



# mpg123 /home/thierry/Téléchargements/Cuisinella_Jingle.mp3



mpg123 /home/thierry/Téléchargements/Cuisinella_Jingle.mp3 &> /dev/null





