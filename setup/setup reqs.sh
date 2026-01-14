clear
# Uncomment the below lines if you want to run updates and upgrades as part of the install process
#echo "Updating and upgrading PC..."
# sudo apt update && sudo apt upgrade -y

# Microsoft Fonts are needed for windows applications to show properly
clear
echo "Installing Microsoft Fonts..."
sleep 3
sudo apt-get install -y ttf-mscorefonts-installer
fc-cache -f -v

# wget will be used later to install yabridge
clear
echo "Installing wget..."
sleep 3
sudo apt-get install -y wget

# Pipewire is necessary for adjusting sample rates and buffer sizes
clear
echo "Installing Pipewire..."
sleep 3
sudo apt-get install -y pipewire pipewire-jack pipewire-alsa pipewire-pulse

# pactl is for retrieving data about your audio devices
clear
echo "Install pactl..."
sudo apt-get install -y pulseaudio-utils

# Wine 9.21 Installation Script
# This script installs Wine 9.21 staging with 32-bit compatibility
#!/bin/bash

# 1. Enable 32-bit architecture
echo "Enabling 32-bit architecture for wine32..."
sudo dpkg --add-architecture i386

# 2. Identify Distribution and Codename
OS_ID=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
OS_CODENAME=$(lsb_release -cs)

echo "Detected System: $OS_ID ($OS_CODENAME)"

# 3. Download and add WineHQ GPG key
sudo mkdir -pm 755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# 4. Add the correct repository based on OS
case "$OS_ID" in
    ubuntu)
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$OS_CODENAME/winehq-$OS_CODENAME.sources
        ;;
    debian)
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$OS_CODENAME/winehq-$OS_CODENAME.sources
        ;;
    *)
        echo "Unsupported distribution: $OS_ID"
        exit 1
        ;;
esac

# 5. Update package lists
sudo apt update

# 6. Install Wine 9.21 (Development Branch)
# Note: As of this script's context, 9.21 is a specific dev version.
# To pin a specific version, we specify it in the apt install command.
echo "Installing Wine 9.21 and 32-bit dependencies..."
sudo apt install --install-recommends \
    winehq-devel=9.21~$OS_CODENAME-1 \
    wine-devel=9.21~$OS_CODENAME-1 \
    wine-devel-amd64=9.21~$OS_CODENAME-1 \
    wine-devel-i386=9.21~$OS_CODENAME-1

# yabridge is necessary to run windows plugins
clear
echo "Installing yabridge..."
wget -qO- https://api.github.com/repos/robbert-vdh/yabridge/releases/latest | grep "yabridge.*tar.gz" | cut -d : -f 2,3 | tr -d \" | xargs wget

find . -name 'yabridge*.tar.gz' -exec tar -xzf {} -C . \;
find . -name 'yabridge*.tar.gz' -exec rm {} \;

mv ./yabridge $HOME/.local/share

echo -e "\nexport PATH=\"\$PATH:\$HOME/.local/share/yabridge\"" >> ~/.bashrc
source ~/.bashrc
echo "Making directories..."
mkdir -p "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins" "$HOME/.wine/drive_c/Program Files/Common Files/VST3" "$HOME/.wine/drive_c/Program Files/Common Files/CLAP" "$HOME/Documents/vsts/dll and vst3 files"
yabridgectl add "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"
yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"
yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/CLAP"
yabridgectl add "$HOME/Documents/vsts/dll and vst3 files"

echo "Starting yabridge host..."
$HOME/.local/share/yabridge/yabridge-host.exe

$HOME/.local/share/yabridge/yabridgectl sync
$HOME/.local/share/yabridge/yabridgectl status
clear
echo 
echo "This setup is now complete."
echo 
yabridgectl --version
echo
echo "If you do not see an output reading 'yabridgectl x.x.x' above this line then you will need to reboot your pc and run the yabridgectl setup again."
echo
read -p "Do you want to reboot the system now? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Reboot canceled."
    echo "It is recommended you reboot before using any installed packages."
fi
