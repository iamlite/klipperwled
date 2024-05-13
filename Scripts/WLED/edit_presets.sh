#!/bin/sh


########################################################
#################  FIND BASE DIRECTORY #################
########################################################

# Start from the directory of the current script and find the base directory
DIR=$(dirname "$(realpath "$0")")
while [ "$DIR" != "/" ]; do
    if [ -f "$DIR/VERSION" ]; then
        BASE_DIR=$DIR
        break
    fi
    DIR=$(dirname "$DIR")
done

if [ -z "$BASE_DIR" ]; then
    echo "Failed to find the base directory. Please check your installation." >&2
    exit 1
fi

# Script directory
SCRIPT_DIR="$BASE_DIR/Scripts"

# Source common functions
. "$SCRIPT_DIR/common_functions.sh"

########################################################
########################################################
########################################################

# Config file path
config_file="$BASE_DIR/Config/presets.conf"

# Function to display the stored presets with options A, B, C, etc., and an option to return to the main menu
show_presets() {
    print_item "$green Current WLED Presets:$NC"
    i=0
    while IFS= read -r line; do
        if [ $i -gt 0 ]; then
            print_spacer
        fi
        char=$(awk -v num=$i 'BEGIN {printf "%c", 65 + num}')
        print_nospaces "$char: $line"
        i=$((i + 1))
    done < "$config_file"
    print_spacer
    print_nospaces "X: Return to main menu"
    print_separator
}

# Function to edit a preset or return to the main menu
edit_preset() {
    print_input_item "$MAGENTA Enter the letter of the preset you want to edit (A, B, C, ..., X for main menu):"
    read choice
    choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')  # Normalize input
    if [ "$choice" = "X" ]; then
        return 1  # Return a specific non-zero status to indicate menu return
    fi
    line_num=$(printf "%d" "'$choice")
    line_num=$((line_num - 65 + 1))
    if [ $line_num -gt 0 ] && [ $line_num -le $i ]; then
        event_name=$(sed -n "${line_num}p" "$config_file" | cut -d':' -f1)
        print_input_item "$MAGENTA Enter the new preset number for $event_name: "
        read new_number
        while ! echo "$new_number" | grep -E -q '^[0-9]+$'; do
            print_item "$red Invalid input. Please enter a valid preset number:$NC"
            read new_number
        done
        sed -i "${line_num}s/^$event_name: .*$/$event_name: $new_number/" "$config_file"
        [ $? -eq 0 ] && print_item "$green Preset updated successfully.$NC" || print_item "$red Failed to update preset. Check your permissions or path.$NC"
    else
        print_input_item "$red Invalid selection. Please enter a valid letter.$NC"
    fi
}

# Main logic
clear
quit=0
while [ $quit -eq 0 ]; do
    if [ -f "$config_file" ]; then
        clear
        show_presets
        edit_preset
        quit=$?  # Capture the return status to decide if the loop should continue
    else
        print_item "$red No preset configuration file found. Please run setup first.$NC"
        break
    fi
done

print_item "$blue Press enter to return to the menu...$NC"
read dummy
