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

# 1. Enable 32-bit architecture
echo "Enabling 32-bit architecture..."
sudo dpkg --add-architecture i386

# 2. Identify the Base Distribution
# We check /etc/os-release for the ID or ID_LIKE fields
if grep -qi "ubuntu" /etc/os-release; then
    BASE_DISTRO="ubuntu"
    # For Ubuntu derivatives, we need the underlying Ubuntu codename (e.g., 'noble' or 'jammy')
    CODENAME=$(. /etc/os-release; echo $UBUNTU_CODENAME)
    # Fallback if UBUNTU_CODENAME is empty (some distros don't set it)
    [[ -z "$CODENAME" ]] && CODENAME=$(lsb_release -cs)
elif grep -qi "debian" /etc/os-release; then
    BASE_DISTRO="debian"
    CODENAME=$(lsb_release -cs)
else
    echo "Error: This system does not appear to be based on Debian or Ubuntu."
    exit 1
fi

echo "Detected Base: $BASE_DISTRO"
echo "Detected Codename: $CODENAME"

# 3. Setup WineHQ Keyring
sudo mkdir -pm 755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# 4. Add Repository based on the detected Base
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/$BASE_DISTRO/dists/$CODENAME/winehq-$CODENAME.sources

# 5. Update and Install
sudo apt update

# Installing 9.21 specifically across all necessary components
echo "Installing Wine 9.21 for $CODENAME..."
sudo apt install --install-recommends \
    winehq-devel=9.21~$CODENAME-1 \
    wine-devel=9.21~$CODENAME-1 \
    wine-devel-amd64=9.21~$CODENAME-1 \
    wine-devel-i386=9.21~$CODENAME-1

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
