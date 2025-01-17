# Deckpad

> ⚠️ **WARNING:** This is a mostly stable prototype, but it is very much alpha!

> ⚠️ After updating to Steam OS 3.4 you need to update the `Launch Options`   
> You need to add `--fullscreen`
> - Old: `-u LD_PRELOAD konsole --fullscreen -e ./deckpad.sh`
> - New: `-u LD_PRELOAD konsole -e ./deckpad.sh`

> ⚠️ **WARNING:** If you quit Deckpad without pressing on the screen (or if it doesn't work on your device), it won't clean up and will prevent sleep and brightness changes!
> - The easiest way way to fix it is to run Deckpad again, and quit it by clicking on the target in the middle of the screen  
> - Alternatively, you can restore the SteamDeck to its original state by running these 2 commands:
>   ```bash
>   sudo chmod 666 /sys/class/backlight/amdgpu_bl0/brightness
>   sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null 2>&1
>   ```

## What is Deckpad?

Deckpad allows you to use your SteamDeck as a gamepad on your Windows PC.

Once setup, all you have to do is to launch **Deckpad**, enter your password, and it will:

* Connect automatically to your Windows PC and act as a gamepad
   * You can use all the Steam input config you already configured on the SteamDeck
* Reduce the brightness to the minimum
   * Also prevents Steam from raising it while the app is running
* Disable sleep mode while the app is running
* Show the live battery percentage

Welcome Screen              |  Running Screen
:-------------------------:|:-------------------------:
![](https://github.com/FlorianKempenich/Deckpad/raw/main/doc/welcome_screen.jpg)  |  ![](https://github.com/FlorianKempenich/Deckpad/raw/main/doc/running_screen.jpg)


## Setup Instructions
> **Update Instructions**
> ```
> cd ~/Deckpad/ && git pull
> ```
### On Steam Deck

1. Set a `sudo` password: [SteamDeckTips Tutorial](https://steamdecktips.com/blog/how-to-set-a-password-for-your-steam-deck-user-in-desktop-mode)
2. Clone repo
    
    ```bash
    cd ~ && git clone https://github.com/FlorianKempenich/Deckpad.git
    ```
    
3. Run `./install.sh`
    
    This will:
    
    - Disable `readonly` mode on SteamOS
    - Initialize `pacman`
    - Install `xorg-xinput` and `figlet`
    - Download VirtualHere
    - Create shortcuts.vdf (if needed)
    - Add shortcut to deckpad.sh

10. Launch it once


### On Windows Gaming PC

1. Download [VirtualHere Client for Windows (64-Bit Win10,Win11/Server 2016/2019/2022](https://www.virtualhere.com/sites/default/files/usbclient/vhui64.exe)
2. Place `.exe` at the root of `C:` drive
3. Configure it
    1. Launch Deckpad on the Steam Deck
    2. Run `vhui64.exe`
    3. *Steam Controller should show (it can take a bit before it shows)*
    4. Right click on `USB Hubs` and select
        1. `Start minimized`
        2. `Always On Top`
        3. *(can’t use `Install Client as a Service`, it requires the paid version)*
    5. Right click on `Steam Controller` and select
        1. `Auto-Use Device`
4. Place a shortcut of `vhui64.exe` in `shell:startup`