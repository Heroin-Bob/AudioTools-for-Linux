# AudioTools For Linux (Ubuntu/Debian-based Only)

<img width="420" height="555" alt="image" src="https://github.com/user-attachments/assets/85a91a39-003e-43b2-b8af-0b430c57a107" />


This is a GUI tool developed in C# designed to enhance the ease-of-use of command-line interface audio tools in <a href="https://distrowatch.com/search.php?basedon=Ubuntu#simpleresults">Ubuntu based</a> Linux environments. I've included and simplified the setup and installation processes as part of the development of this tool. Currently, this tool is meant for Ubuntu and Ubuntu-based distributions.

If you would like to fork this tool and modify it to work in non-Ubuntu based distros or another language like Python I would be happy to refer to your fork from this project. See the FAQ for more info on this.

## Requirements
All requirements are in the <b>setup reqs.sh</b> file. You do not need to install from any link below, this is just a list of requirements. Installation instructions will follow this section:
- yabridge: https://github.com/robbert-vdh/yabridge
- WINE (Pre-9.21 ONLY. 9.21 breaks yabridge): The setup for this installs from apt and will install version 6.0.3 or 9.0 (depending on your setup). If you use a more modern version of wine you will need to uninstall it (See FAQ)
- Microsoft Fonts
- wget
- dotnet 8.0
- Pipewire: https://www.pipewire.org/

## How To Setup

This instructional is going to assume you have a fresh install of an Ubuntu-based distro. I can't account for everything going on in your daily driver.

You can follow the steps below or open the <b>setup reqs.sh</b> file (it is not advised to run the .sh file as it is, but rather take it section-by-section - but I'm not going to tell you how to live your life):

Make sure you are fully updated with the following command: ```sudo apt update && sudo apt upgrade -y```

<details>
<summary><b>Setup for AudioTools only</b></summary>
<br>
If you are already using yabridge and already have pipewire then you do not need to go through the full setup. You can download the AudioTools file directl from the releases page and it should work!

If you are looking to build AudioTools (not necessary for running, only building) you will need to install dotnet 8.0

Use the commands below to download dotnet 8.0:

   ```
   wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
   sudo dpkg -i packages-microsoft-prod.deb
   rm packages-microsoft-prod.deb
   sudo apt-get install -y dotnet-sdk-8.0
   sudo apt-get install -y aspnetcore-runtime-8.0
   sudo apt-get install -y dotnet-runtime-8.0
   ```
Once completed you can download AudioTools from the Releases page https://github.com/Heroin-Bob/AudioTools-for-Linux/releases.
</details>

<details>
<summary><b>Automated Full Setup</b></summary>
<br>
To automatically perform all the necessary steps to install all the requirements download the <b>setup reqs.sh</b> file from the assets and run it. Be sure to monitor it and accept any options that come up.

When the script reaches the end you will be prompted with a check to see if yabridge was set up successfully. If it was not, reboot your pc then run the yabridge setup script again: https://github.com/Heroin-Bob/AudioTools-for-Linux/blob/main/setup/setup%20yabridge.sh

Note: After the reboot you will be able to run ```yabridgectl --version``` and get the version number in response. However, this does not mean it is set up. There are directories that need to be mapped in yabridge for it to work properly. Run the script as recommended.

You can now download AudioTools from the Releases page https://github.com/Heroin-Bob/AudioTools-for-Linux/releases.
</details>

<details>
<summary><b>Manual Full Setup</b></summary>
<br>
If you do not have anything installed from the requirements list below are the steps to go through to get everything working. Be sure to follow each step exactly as it is written.

1. Verify dotnet installed by opening a terminal and entering ```dotnet --version```. At the time of writing this it should return ```8.0.117```.
2. We will use <b>wget</b> to automate the yabridge install process. Install wget with the following command: ```sudo apt-get install -y wget```
3. Verify wget was installed with ```wget --version```. At the time of writing this apt installs version 8.5.0.
4. Install Wine/Wine32 from apt 
   Note: this will install version 9.21 from apt. If you have a newer version of WINE installed you will need to uninstall it (see the FAQ for more info). You cannot use yabridge with any version newer than 9.21.<br>
    ```
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
   ```
5. Verify WINE was installed by running ```wine --version```
6. Install Microsoft Fonts (and refresh your font cache) with the following code:<br>
    ```
    sudo apt-get install -y ttf-mscorefonts-installer
    fc-cache -f -v
    ```
7. Install all versions of Pipewire with the following command: ```sudo apt-get install -y pipewire pipewire-jack pipewire-alsa pipewire-pulse```
8. Reboot your system.
9. Download and configure yabridge with the following commands:<br>
   ```
   wget -qO- https://api.github.com/repos/robbert-vdh/yabridge/releases/latest | grep "yabridge.*tar.gz" | cut -d : -f 2,3 | tr -d \" | xargs wget

   find . -name 'yabridge*.tar.gz' -exec tar -xzf {} -C . \;
   find . -name 'yabridge*.tar.gz' -exec rm {} \;
   
   mv ./yabridge $HOME/.local/share
   
   echo -e "\nexport PATH=\"\$PATH:\$HOME/.local/share/yabridge\"" >> ~/.bashrc
   source ~/.bashrc
   sleep 5
   echo "Making directories..."
   mkdir -p "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins" "$HOME/.wine/drive_c/Program Files/Common Files/VST3" "$HOME/.wine/drive_c/Program Files/Common Files/CLAP" "$HOME/Documents/vsts/dll and vst3 files"
   sleep 5
   yabridgectl add "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"
   yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"
   yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/CLAP"
   yabridgectl add "$HOME/Documents/vsts/dll and vst3 files"
   
   echo "Starting yabridge host..."
   $HOME/.local/share/yabridge/yabridge-host.exe
   
   $HOME/.local/share/yabridge/yabridgectl sync
   $HOME/.local/share/yabridge/yabridgectl status
   ```
10. Verify yabridge was installed by running ```yabridgectl --version```.
11. Download the most recent release: https://github.com/Heroin-Bob/AudioTools-for-Linux/releases<br>
    Note: If you want to build the app yourself you can download all the project files then run the <b>Run this to build.sh</b> file and it will build the app for you. You can find the final app in the directory you built the file from by drilling down into <b>bin/Release/net8.0/linux-x64/publish</b>. You do not need any of the other files besides the AudioTools exe file. It is fully self-contained. Though if you are not on a fork of Ubuntu you will need to modify the commands for your system.

At this point your setup is finished and you can now install and use Windows plugins and keep up with them via the AudioTools GUI.

</details>


## FAQ
<b><i>Why does the WINE version need to be less than 9.21?</i></b><br>
Because based Robbert-vdh, the creator of yabridge says so (9.21 introduced graphical bugs in yabridge that haven't been resolved). https://github.com/robbert-vdh/yabridge?tab=readme-ov-file#known-issues-and-fixes<br><br>
<b><i>How do I downgrade WINE?</b></i><br>
If you want to downgrade you can read this: https://github.com/robbert-vdh/yabridge?tab=readme-ov-file#downgrading-wine<br>. That being said, I had issues when I tested this out and ended up needing to rebuild my .wine folder completely. I would recommend archiving all the files within the /Home/.wine directory, move that archive to another folder, deleting the entire .wine directory, uninstalling WINE, then installing the correct version, then adding the directory back in. You'll probably need to reconfigure winecfg to your preferences afterwards.<br><br>
<b><i>Why did you build this GUI when you can do everything from the command line?</i></b><br>
Because having to stop working on music to type or copy-paste commands into a terminal sucks, and when you're working with other people it really makes audio production on Linux look bad by comparison. I just want to click a button and have it do what I need it to do. This gives me those buttons.<br><br>
<b><i>Why is this made in C# and not Python</b></i><br>
I tried to use Python since I know everyone uses it, but I simply couldn't get it to do what I wanted it to do. Every time I would get it working it would break after running pyinstaller! I had multiple people look at it and no one could make it make sense. After a week of slamming my head against my keyboard I abandoned it. I have a background in C# anyway, so that's what I went with, and it worked great. It is easier for me to code and easier for me to expand on later. If you'd like to port this over to Python then be my guest. But, if you need the terminal to run it at all then you're defeating the point of the GUI even existing.<br><br>
<b><i>Will this work for distrobutions not built on Ubuntu or Debian?</b></i><br>
Nope. I built this specifically for Debian based systems because that is what I know and it seems to be what most people land on when they're migrating to Linux. If you have the ability to develop forks of this I'll be happy to recommend your fork at the top of this repo. However, I will not list your repo if it does not completely remove the need for the terminal, have a concise .md file (modifying this one would be fine), and include updated setup files. If you are looking for forks for other distros and you do not see any here then there probably aren't any.
