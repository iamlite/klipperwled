#!/bin/sh

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$(realpath "$0")")"  # Determines the absolute path of the directory of this script

# Function to print a horizontal line separator
print_separator() {
    local separator_length=$(tput cols)
    local separator_char="="
    printf "${CYAN}%s${NC}\n" "$(printf "%${separator_length}s" | tr ' ' "$separator_char")"
}

# Function to print menu items with a double border on the left
print_menu_item() {
    local item=$1
    local color=$2
    printf "${CYAN}||${NC} ${color}${item}${NC}\n"
}

print_spacer() {
    printf "${CYAN}||${NC}\n"
}

# Function to display the main menu with spacing
show_menu() {
    clear
    print_separator
    print_menu_item "WLED Klipper Setup Helper" "$GREEN"
    print_separator
    print_spacer
    print_menu_item "1. Setup WLED" "$YELLOW"
    print_spacer
    print_menu_item "2. Setup WLED Presets" "$YELLOW"
    print_spacer
    print_menu_item "3. Add Macros" "$YELLOW"
    print_spacer
    print_menu_item "4. View and Edit Preset Numbers" "$YELLOW"
    print_spacer
    print_menu_item "5. Quit" "$YELLOW"
    print_spacer
    print_separator
    printf "${CYAN}================================================================================${NC}\n"
    printf "${MAGENTA}Please enter your choice: ${NC}"
}

# Confirmation before proceeding
confirm_proceed() {
    printf "${BLUE}You chose to $1.${NC}\n"
    printf "${MAGENTA}$2${NC}\n"
    printf "${GREEN}Proceed? (y/n): ${NC}"
    read yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        sh "${SCRIPT_DIR}/$3"  # Execute the script using its absolute path
    else
        printf "${RED}Action cancelled by the user.${NC}\n"
    fi
}

# Main loop
while true; do
    show_menu
    read choice
    case "$choice" in
        1) confirm_proceed "setup WLED" "This will configure your WLED instance including IP address, LED count, and initial presets. It's essential for integrating WLED with your Klipper printer." "setup_wled.sh" ;;
        2) confirm_proceed "setup WLED Presets" "This will help you create and configure presets in your WLED setup for various printer events like pause, cancel, or resume." "setup_presets.sh" ;;
        3) confirm_proceed "add Macros" "This option allows you to search and add specific macros to your printer's configuration, enabling more sophisticated control over your printer's behaviors." "add_macros.sh" ;;
        4) confirm_proceed "view and edit preset numbers" "This allows you to view and modify the preset numbers assigned to different printer states, ensuring they match your current WLED setup." "view_edit_presets.sh" ;;
        5) printf "${BLUE}Exiting...${NC}\n"; break ;;
        *) printf "${RED}Invalid option, try again...${NC}\n" ;;
    esac
    printf "${BLUE}Press enter to continue...${NC}\n"
    read dummy
done
