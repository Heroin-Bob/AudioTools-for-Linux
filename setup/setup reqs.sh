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

# check if wine is already there
wine_installed=false
wine_version_ok=false

if command -v wine >/dev/null 2>&1; then
    echo "Found wine already installed"
    wine_installed=true
    
    # get version number - this is a bit hacky but works
    wine_ver=$(wine --version)
    echo "Current wine version: $wine_ver"
    
    # extract just the numbers like 9.2 from wine-9.2
    current_ver=$(echo $wine_ver | sed 's/wine-//' | cut -d'-' -f1 | cut -d' ' -f1)
    
    # simple version check - just compare major.minor
    if [[ $current_ver == "9.2" || $current_ver > "9.2" ]]; then
        echo "Wine version is good enough (v = 9.2)"
        wine_version_ok=true
    else
        echo "Wine version is too old, need to upgrade"
    fi
else
    echo "Wine not installed yet"
fi

# only install if wine isn't already installed
if [[ $wine_installed == false ]]; then
    echo "Need to install Wine 9.2"
    
    # figure out what distro we're on
    if [[ -f /etc/os-release ]]; then
        # grab the info from the file
        source /etc/os-release
        echo "Found OS: $NAME $VERSION_ID"
        distro_id=$ID
        os_version=$VERSION_ID
    else
        echo "Can't tell what OS this is, just assume ubuntu"
        distro_id="ubuntu"
        os_version="22.04"
    fi
    
    # add 32bit support first
    echo "Adding 32bit architecture"
    sudo dpkg --add-architecture i386
    sudo apt-get update
    
    # setup wine repo based on distro
    if [[ $distro_id == "ubuntu" ]]; then
        echo "Setting up wine repo for ubuntu $os_version"
        
        # get the key
        sudo mkdir -p /etc/apt/keyrings
        sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
        
        # get the right sources file for the version
        case "$os_version" in
            "20.04"|"22.04"|"23.10"|"24.04"|"24.10")
                echo "Getting sources for ubuntu $os_version"
                sudo wget -P /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$os_version/winehq-$os_version.sources
                ;;
            *)
                echo "Unknown ubuntu version, using jammy (22.04) as fallback"
                sudo wget -P /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
                ;;
        esac
        
    elif [[ $distro_id == "debian" ]]; then
        echo "Setting up wine repo for debian $os_version"
        
        # get the key
        sudo mkdir -p /etc/apt/keyrings
        sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
        
        # get the right sources file for the version
        case "$os_version" in
            "11"|"12")
                echo "Getting sources for debian $os_version"
                sudo wget -P /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$os_version/winehq-$os_version.sources
                ;;
            *)
                echo "Unknown debian version, using bookworm (12) as fallback"
                sudo wget -P /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
                ;;
        esac
    else
        echo "Don't know this OS, trying generic install"
    fi
    
    # update again to get the new repo
    echo "Updating package lists..."
    sudo apt-get update
    
    # install wine stable (should be 9.2)
    echo "Installing Wine (this might take a while)..."
    sudo apt-get install -y winehq-stable
    
    # install 32bit wine
    echo "Installing Wine32..."
    sudo apt-get install -y wine32:i386
    
    # check if it worked
    if command -v wine >/dev/null 2>&1; then
        final_version=$(wine --version)
        echo "Done! Wine version: $final_version"
    else
        echo "Hmm, wine doesn't seem to be working right"
    fi
    
else
    echo "Wine is already good, skipping install"
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
