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

# Install Wine 9.2
clear
echo "Installing Wine 9.2..."
sleep 3

# 1. Detect the distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Detected distribution: $NAME $VERSION_ID"
    
    # 2. Detect whether that distro is running on ubuntu or debian
    if [ "$ID" = "ubuntu" ]; then
        BASE_DISTRO="ubuntu"
        BASE_VERSION="$VERSION_ID"
        echo "Base distro: Ubuntu $BASE_VERSION"
    elif [ "$ID" = "debian" ]; then
        BASE_DISTRO="debian"
        BASE_VERSION="$VERSION_ID"
        echo "Base distro: Debian $BASE_VERSION"
    elif [ "$ID" = "linuxmint" ]; then
        # Linux Mint is based on Ubuntu
        BASE_DISTRO="ubuntu"
        case "$VERSION_ID" in
            "21"*)
                BASE_VERSION="22.04"
                ;;
            "22"*)
                BASE_VERSION="22.04"
                ;;
            *)
                BASE_VERSION="22.04"
                ;;
        esac
        echo "Base distro: Ubuntu $BASE_VERSION (Linux Mint $VERSION_ID)"
    else
        echo "Unsupported distribution: $ID"
        exit 1
    fi
else
    echo "Cannot detect distribution"
    exit 1
fi

# 3. Determine which version of ubuntu or debian the distro is on
# (Already done above with BASE_VERSION)

# 4. Find the appropriate version of wine 9.2 that matches that version from winehq.org
# 5. Download the appropriate version
# 6. Install that specific distro's release of wine 9.2

# Add 32-bit architecture support
sudo dpkg --add-architecture i386

# Create keyrings directory and add WineHQ GPG key
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# Add repository based on detected base distro and version
if [ "$BASE_DISTRO" = "ubuntu" ]; then
    case "$BASE_VERSION" in
        "20.04"|"focal")
            REPO_DISTRO="focal"
            ;;
        "22.04"|"jammy")
            REPO_DISTRO="jammy"
            ;;
        "24.04"|"noble")
            REPO_DISTRO="noble"
            ;;
        *)
            REPO_DISTRO="jammy"
            echo "Using Ubuntu 22.04 (Jammy) repository for compatibility"
            ;;
    esac
    
    # Download Ubuntu repository file
    sudo wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/${REPO_DISTRO}/winehq-${REPO_DISTRO}.sources"
    
elif [ "$BASE_DISTRO" = "debian" ]; then
    case "$BASE_VERSION" in
        "10"|"buster")
            REPO_DISTRO="buster"
            ;;
        "11"|"bullseye")
            REPO_DISTRO="bullseye"
            ;;
        "12"|"bookworm")
            REPO_DISTRO="bookworm"
            ;;
        *)
            REPO_DISTRO="bookworm"
            echo "Using Debian 12 (Bookworm) repository for compatibility"
            ;;
    esac
    
    # Download Debian repository file
    sudo wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/debian/dists/${REPO_DISTRO}/winehq-${REPO_DISTRO}.sources"
fi

# Update package lists
sudo apt-get update

# Install Wine 9.2 stable specifically
echo "Installing Wine 9.2..."
sudo apt-get install -y --install-recommends winehq-stable=9.2~*
sudo apt-get install -y wine32:i386

# Verify installation
if command -v wine >/dev/null 2>&1; then
    wine_version=$(wine --version)
    echo "Wine 9.2 installed successfully: $wine_version"
else
    echo "Wine installation failed"
    exit 1
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
