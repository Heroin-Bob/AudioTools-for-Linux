sudo apt update && sudo apt upgrade -y

echo "Installing dotnet 8.0"
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get install -y dotnet-sdk-8.0
sudo apt-get install -y aspnetcore-runtime-8.0
sudo apt-get install -y dotnet-runtime-8.0

echo "Installing curl"
sudo apt-get install -y curl

echo "Installing Wine:"
sudo apt-get install -y wine 

sudo dpkg --add-architecture i386
sudo add-apt-repository ppa:ubuntu-wine/ppa
sudo apt-get update
sudo apt-get install wine1.8
sudo apt-get install -y wine32


echo "Installing Microsoft Fonts:"
sudo apt-get install -y ttf-mscorefonts-installer
fc-cache -f -v
	
echo "Installing Pipewire..."
sudo apt-get install -y pipewire pipewire-jack pipewire-alsa pipewire-pulse

echo "Downloading yabridge, moving to appropriate folder, and adding .bashrc path:"

curl -s https://api.github.com/repos/robbert-vdh/yabridge/releases/latest \
| grep "yabridge.*tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

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
