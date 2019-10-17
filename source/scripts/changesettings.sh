#!/bin/bash
# Changes settings in configuaration files that can be set by the user

displayCurrentSettings() {
    echo "Current global settings:"
    echo "Configuration file: $configPath"
    echo "Default editor: $editor"
    echo "Auto Update: $autoUpdate"
    echo
}

changeStr() {
    echo
    local displayString=$1
    local variableToChange=$2
    local fileToChange=$3
    # Reads input from the user
    read -p "$displayString" input
    # Removes the current variable from the config
    grep -v "$variableToChange" $fileToChange > $fileToChange.tmp && mv $fileToChange.tmp $fileToChange
    # Adds the new variable to the file
    echo -e "$variableToChange=$input" >> $fileToChange
}

findRepo() {
    # 
    for i in ${repoPaths[@]}; do
        repoConfigPath=$i/.trackpro/repo.conf
        source $repoConfigPath
        if [ "$name" == "$repoInput" ]; then
            found=true
            break;
        fi
    done
}

repoName() {
    echo $trackproPath
    # 
    source $trackproPath/scripts/listrepos.sh $repoPaths
    #
    found=false
    #
    while [ "$found" == "false" ]; do
        # Reads input from the user
        read -p "What repository would you like to change the name of? " repoInput
        #
        findRepo
        if [ "$found" == "true" ]; then
            changeStr "What do you want to change $name to be? " name $repoConfigPath
        else
            echo "Repository name is invalid"
        fi
    done
}

editor() {
    # Asks the user for input and deletes the current command from the file
    changeStr "New editor command: " editor $configPath
    # Adds the new editor variable to the file
    # echo -e "editor=$input" >> $configPath
}

changeBool() {
    local displayStringIfTrue=$1
    local displayStringIfFalse=$2
    local variableToChange=$3
    local fileToChange=$4
    source $fileToChange
    if [ "${!variableToChange}" == true ]; then
        read -p "$displayStringIfTrue" yn
        case $yn in
            [Yy]* )
                #
                grep -v "$variableToChange" $fileToChange > $fileToChange.tmp && mv $fileToChange.tmp $fileToChange
                # Adds the new editor variable to the file
                echo -e "$variableToChange=false" >> $fileToChange
            ;;
            * )
                echo "No action taken"
            ;;
        esac
    else
        read -p "$displayStringIfFalse" yn
        case $yn in
            [Nn]* )
                echo "No action taken"
            ;;
            * )
                grep -v "$variableToChange" $fileToChange > $fileToChange.tmp && mv $fileToChange.tmp $fileToChange
                # Adds the new editor variable to the file
                echo -e "$variableToChange=true" >> $fileToChange
            ;;
        esac
    fi
}

# Allows the user to change if a repository auto-compiles when a change is stored
autoCompile() {
    # Lists all the repositories
    source $trackproPath/scripts/listrepos.sh $repoPaths
    #
    found=false
    #
    while [ "$found" == "false" ]; do
        # Reads input from the user
        read -p "What repository would you like to turn on/off automatic compilation? " repoInput
        #
        findRepo
        # 
        if [ "$found" == "true" ]; then
            changeBool "Would you like to turn off automatic compilation? [Y/n] " "Would you like to turn on automatic compilation? [Y/n] " makeOnStore $repoConfigPath
        else
            echo "Repository name is invalid"
        fi
    done
}

# Displays the menu and processes the options available to the user
menu() {
    # Credits to askubuntu user Dennis Williamson
    # Link: https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script
    # Prints to the console
    PS3='Please enter your choice: '
    # Defines the options for a user to select
    options=("Default editor" "Change repository name" "Enable/Disable automatic comilation" "Exit")
    # Allows the user to type in their prefered option
    select opt in "${options[@]}"
    do
        # Chooses the function based on the user's statement
        case $opt in
            "Default editor")
                editor
                break
            ;;
            "Change repository name")
                repoName
                break
            ;;
            "Enable/Disable automatic comilation")
                autoCompile
                break
            ;;
            "Exit")
                break
            ;;
            *)
                # Prints what the user's typed
                echo "Invalid Option: $REPLY"
                echo "Please enter an invalid"
            ;;
        esac
    done
}

# Contains the main program
main() {
    absolutePath
    # Sets the path to the main trackpro configuration file as imported from the main script
    configPath=$1
    #
    trackproPath=$2
    # Imports the variables from this configuration file
    source $configPath
    # Displays the current settings 
    displayCurrentSettings
    # Displays the menu and processes the options
    menu
}

# Runs the main program
main $1 $2