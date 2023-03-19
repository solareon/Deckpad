#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR" || exit
set -o pipefail

function run_as_root() {
    source ./functions.sh

    # Start
    set_brightness_to_minimum
    disable_sleep
    start_virtualhere

    # Run - Block until Tap on screen
    run_prompt_start
    block_until_press_on_target

    # Quit
    run_prompt_stop
    quit_prompt &
    quit_prompt_pid=$!
    restore_brightness
    reenable_sleep
    stop_virtualhere
    wait quit_prompt_pid
}

# Check if the user has root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run with root privileges. Elevating..." >&2
  exec sudo "$0" "$@"
else
    source ./functions.sh
    prepare_fullscreen

    xhost local:root >/dev/null
    FUNC=$(declare -f run_as_root)
    bash -c "$FUNC; run_as_root"

    cd - >/dev/null || exit
fi