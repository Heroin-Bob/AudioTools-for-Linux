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

set -e  # Exit on any error

echo "Starting Wine 9.21 installation..."

# Add i386 architecture for 32-bit support
echo "Adding i386 architecture..."
sudo dpkg --add-architecture i386

# Download and add Wine repository key
echo "Downloading Wine repository key..."
wget -nc https://dl.winehq.org/wine-builds/winehq.key

echo "Adding Wine repository key..."
sudo mkdir -pm755 /etc/apt/keyrings
wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -


# Add Wine repository
echo "Adding Wine repository..."
sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ focal main"

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install Wine 9.21 staging packages
echo "Installing Wine 9.21 staging packages..."
sudo apt install --install-recommends wine-staging-i386=9.21~focal-1 -y
sudo apt install --install-recommends wine-staging-amd64=9.21~focal-1 -y
sudo apt install --install-recommends wine-staging=9.21~focal-1 -y
sudo apt install --install-recommends winehq-staging=9.21~focal-1 -y

# Install additional 32-bit compatibility packages
echo "Installing 32-bit compatibility packages..."
sudo apt install --install-recommends wine32 -y
sudo apt install --install-recommends libwine -y

# Install common dependencies for Windows applications
echo "Installing common Windows application dependencies..."
sudo apt install --install-recommends winbind -y
sudo apt install --install-recommends cabextract -y

# Clean up downloaded key file
rm -f winehq.key

echo "Wine 9.21 installation completed!"
echo "You can now configure Wine by running: winecfg"

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
