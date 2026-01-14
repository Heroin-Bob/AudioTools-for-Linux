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

# Is WINE
clear
echo "Checking Wine installation..."
sleep 3

if command -v wine >/dev/null 2>&1; then
    wine_version=$(wine --version)
    echo "Wine is already installed: $wine_version"
    echo "Skipping Wine installation"
else
    echo "Wine not found, proceeding with installation"
    
    # Check what distro we're on
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "Detected: $NAME $VERSION_ID"
        
        # Linux Mint is based on Ubuntu, so handle that case
        if [ "$ID" = "linuxmint" ]; then
            if [ "$VERSION_ID" = "22" ]; then
                echo "Linux Mint 22 detected, using Ubuntu 22.04 repositories"
                BASE_DISTRO="ubuntu"
                BASE_VERSION="22.04"
            fi
        elif [ "$ID" = "ubuntu" ]; then
            BASE_DISTRO="ubuntu"
            BASE_VERSION="$VERSION_ID"
        elif [ "$ID" = "debian" ]; then
            BASE_DISTRO="debian"
            BASE_VERSION="$VERSION_ID"
        fi
    fi
    
    # Add 32-bit architecture
    sudo dpkg --add-architecture i386
    sudo apt-get update
    
    # Add Wine repository
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    
    # Add repository based on base distro
    if [ "$BASE_DISTRO" = "ubuntu" ]; then
        case "$BASE_VERSION" in
            "22.04"|"jammy")
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
                ;;
            "24.04"|"noble")
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
                ;;
            *)
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
                ;;
        esac
    elif [ "$BASE_DISTRO" = "debian" ]; then
        case "$BASE_VERSION" in
            "11"|"bullseye")
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources
                ;;
            "12"|"bookworm")
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
                ;;
            *)
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
                ;;
        esac
    fi
    
    sudo apt-get update
    sudo apt-get install -y --install-recommends winehq-stable=9.2~*
    sudo apt-get install -y wine32:i386
    
    wine --version
fi
sleep 3

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
