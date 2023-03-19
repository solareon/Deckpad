#!/bin/bash
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VH_URL="https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64"
VH_BIN="/usr/local/bin/vhusbdx86_64"
cd "$DIR"

# Check if the user has root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run with root privileges. Elevating..." >&2
  exec sudo "$0" "$@"
else
    # Get the user's Steam profile path
    steam_profile=$(find /home/deck/.steam/steam/ -type d -name "userdata" | head -n 1)
    if [ -z "$steam_profile" ]; then
      echo "Steam profile not found. Aborting." >&2
      exit 1
    fi

    # Get the Steam user ID
    steam_user_id=$(ls "$steam_profile" | head -n 1)
    if [ -z "$steam_user_id" ]; then
      echo "Steam user ID not found. Aborting." >&2
      exit 1
    fi

    # Set the shortcuts.vdf file path
    shortcuts_file="$steam_profile/$steam_user_id/config/shortcuts.vdf"

    # Check if the file exists
    if [ ! -f "$shortcuts_file" ]; then
        # If the file doesn't exist, create it with the required format
        printf '\x00shortcuts\x00\x00\x08\x08' > "$shortcuts_file"
        echo "The shortcuts.vdf file has been created."
    fi

    # Creating shortcut entry to add to shortcuts.vdf
    entryID=$(($(date +%s%N)/1000000000))
    appName="Deckpad"
    unquotedPath="/usr/bin/env"
    startDir="${DIR}"
    iconPath="${DIR}/icon.ico"
    shortcutPath=""
    launchOptions="-u LD_PRELOAD konsole --fullscreen -e ./deckpad.sh"
    isHidden="0"
    allowDeskConf="0"
    allowOverlay="1"
    openVR="0"
    tags=""

    # Generate the binary data for the new entry
    # Use # as a delimiter instead of the null byte
    full_entryID=$(printf '#%s#' "$entryID")
    full_appName=$(printf '#appname#%s#' "$appName")
    full_quotedPath=$(printf '#exe#%s#' "$(printf '%q' "$unquotedPath")")
    full_startDir=$(printf '#StartDir#%s#' "$startDir")
    full_iconPath=$(printf '#icon#%s#' "$iconPath")
    full_shortcutPath=$(printf '#ShortcutPath#%s#' "$shortcutPath")
    full_launchOptions=$(printf '#LaunchOptions#%s#' "$launchOptions")
    full_isHidden=$(printf '#IsHidden#%s##' "$isHidden")
    full_allowDeskConf=$(printf '#AllowDesktopConfig#%s##' "$allowDeskConf")
    full_allowOverlay=$(printf '#AllowOverlay#%s##' "$allowOverlay")
    full_openVR=$(printf '#OpenVR#%s##' "$openVR")
    full_lastPlayTime=$(printf '#LastPlayTime#%s' "$(printf '#%.0s' {1..4})")
    full_tags=$(printf '#tags#%s##' "$tags")

    # Replace the # delimiter with the null byte
    newEntry=$(echo "$full_entryID$full_appName$full_quotedPath$full_startDir$full_iconPath$full_shortcutPath$full_launchOptions$full_isHidden$full_allowDeskConf$full_allowOverlay$full_openVR$full_lastPlayTime$full_tags" | tr '#' '\x00')

    if grep -q -F "$full_launchOptions" "${shortcuts_file}"; then
        echo "The entry already exists in the shortcuts.vdf file."
    else
        # Insert the new entry before the final "\x08\x08" sequence
        # Use | as the delimiter in the sed command to avoid conflicts with / in the variable
        sed -i -e "s|\x08\x08$|$newEntry\x08\x08|" "${shortcuts_file}"
        echo "The entry has been added to the shortcuts.vdf file."
    fi

    # Disable SteamOS Readonly mode
    steamos-readonly disable

    # Download VirtualHere USBServer
    curl -fsSL -o ${VH_BIN} ${VH_URL} && chmod +x ${VH_BIN}

    # Populate pacman keys
    pacman-key --init
    pacman-key --populate archlinux

    # Install packages
    pacman -S --noconfirm xorg-xinput
    pacman -S --noconfirm figlet

    # Setup script to run sudo without a password
    echo "Adding NOPASSWD sudo for deckpad.sh"
    echo "deck ALL=(ALL) NOPASSWD: ${DIR}/deckpad.sh" | tee /etc/sudoers.d/deckpad

    # Enable SteamOS Readonly mode
    steamos-readonly enable

    cd - >/dev/null
fi