#!/bin/bash

# Function to display language selection menu
select_language() {
    clear
    echo "Select your language:"
    options=("French" "English")
    selected=0

    while true; do
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "-> ${options[i]}"
            else
                echo "   ${options[i]}"
            fi
        done

        read -rsn1 key
        case $key in
            $'\x1B')  # Handle arrow keys
                read -rsn2 -t 0.1 key
                if [ "$key" == "[A" ] && [ $selected -gt 0 ]; then
                    ((selected--))
                elif [ "$key" == "[B" ] && [ $selected -lt $((${#options[@]}-1)) ]; then
                    ((selected++))
                fi ;;
            $'\n') # Enter key to select
                echo "Selected language: ${options[selected]}"
                case $selected in
                    0) echo "French selected." 

# Script en français
# ... (Ton script français ici)

                        ;;
                    1) echo "English selected." 

# Script en anglais
# ... (Ton script anglais ici)

                        ;;
                esac
                return $selected ;;
        esac
    done
}

# Call the function to select language
select_language
