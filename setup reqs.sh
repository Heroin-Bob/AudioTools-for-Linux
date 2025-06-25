clear
# Uncomment the below lines if you want to run updates and upgrades as part of the install process
#echo "Updating and upgrading PC..."
# sudo apt update && sudo apt upgrade -y

clear
echo "Installing Microsoft Fonts..."
sleep 3
sudo apt-get install -y ttf-mscorefonts-installer
fc-cache -f -v

clear
echo "Installing dotnet 8.0..."
sleep 3
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get install -y dotnet-sdk-8.0
sudo apt-get install -y aspnetcore-runtime-8.0
sudo apt-get install -y dotnet-runtime-8.0

clear
echo "Installing curl..."
sleep 3
sudo apt-get install -y curl

clear
echo "Installing Pipewire..."
sleep 3
sudo apt-get install -y pipewire pipewire-jack pipewire-alsa pipewire-pulse

clear
echo "Installing Wine..."
sleep 3
sudo apt install -y wine
sudo apt autoremove
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt autoremove
clear
echo "Installing Wine32:"
sleep 3
sudo apt-get install -y wine32:i386
wine --version
sleep 3
clear

echo "This setup is now complete."
echo "You will now need to install yabridge."
echo "A full yabridge setup script can be found here: https://github.com/Heroin-Bob/AudioTools-for-Linux/blob/main/setup%20yabridge.sh"
