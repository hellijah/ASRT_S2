# RESTE ENCORE A TESTER !!

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
    if ! [[ $masque_sous_reseau =~ ^[0-9]+$ ]]; then
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