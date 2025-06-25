# AudioTools For Linux

``` diff
! Note: before creating this repo I tested to ensure everything worked.
! Immediately after posting it I tested it again and something with WINE stopped working.
! If you see this message know that this instructional may not be 100% accurate.
```


![image](https://github.com/user-attachments/assets/e83b372d-8708-4ad5-b606-3a6268d0b21d)

This is a GUI tool developed in C# designed to enhance the ease-of-use of command-line interface audio tools in Linux environments. I've included and simplified the setup and installation processes as part of the development of this tool. Currently, this tool is meant for Ubuntu and Ubuntu-based distributions.

If you would like to fork this tool and modify it to work in non-Ubuntu based distros or another language like Python I would be happy to refer to your fork from this project.

## Requirements
All requirements are in the <b>setup reqs.sh</b> file. You do not need to install from any link below, this is just a list of requirements. Installation instructions will follow this section:
- yabridge: https://github.com/robbert-vdh/yabridge
- WINE (Pre-9.21 ONLY. 9.21 breaks yabridge): The setup for this installs from apt and will install version 6.0.3 or 9.0 (depending on your setup). If you use a more modern version of wine you will need to uninstall it (See FAQ)
- Microsoft Fonts
- curl
- dotnet 8.0
- Pipewire: https://www.pipewire.org/

## How To Setup

This instructional is going to assume you have a fresh install of an Ubuntu-based distro. I can't account for everything going on in your daily driver.

You can follow the steps below or open the <b>setup reqs.sh</b> file (it is not advised to run the .sh file as it is, but rather take it section-by-section - but I'm not going to tell you how to live your life):

Make sure you are fully updated with the following command: ```sudo apt update && sudo apt upgrade -y```

<details>
<summary>Setup for AudioTools only</summary>
<br>
If you are already using yabridge and already have pipewire then you do not need to go through the full setup. All you need is to install dotnet 8.0 to run AudioTools.

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
<summary>Automated Full Setup</summary>
<br>
To automatically perform all the necessary steps to install all the requirements download the <b>setup reqs.sh</b> file from the assets and run it. Be sure to monitor it and accept any options that come up.

When it finishes run the command ```yabridgectl --version```. If you do not get a version number back, run these commands and try again:
```
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
```

Once you have verified yabridge is set up correctly you should reboot your PC.

You can now download AudioTools from the Releases page https://github.com/Heroin-Bob/AudioTools-for-Linux/releases.
</details>

<details>
<summary>Manual Full Setup</summary>
<br>
If you do not have anything installed from the requirements list below are the steps to go through to get everything working. Be sure to follow each step exactly as it is written.

1. Dotnet is going to be necessary to run the GUI to perform sample size changes, buffer rate changes, and yabridge syncing (more on this later). Install dotnet 8.0 with the following command:<br>
   ```
   wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
   sudo dpkg -i packages-microsoft-prod.deb
   rm packages-microsoft-prod.deb
   sudo apt-get install -y dotnet-sdk-8.0
   sudo apt-get install -y aspnetcore-runtime-8.0
   sudo apt-get install -y dotnet-runtime-8.0
   ```
2. Reboot your PC
3. Verify dotnet installed by opening a terminal and entering ```dotnet --version```. At the time of writing this it should return ```8.0.117```.
4. We will use <b>curl</b> to automate the yabridge install process. Install curl with the following command: ```sudo apt-get install -y curl```
5. Verify curl was installed with ```curl --version```. At the time of writing this apt installs version 8.5.0.
6. Install Wine from apt 
   Note: this will install version 9.0 (or 6.0.3 depending on your setup) from apt. if you have a newer version of WINE installed you will need to uninstall it (see the FAQ for more info). You cannot use yabridge with any version newer than 9.20.<br>
    ```
   sudo apt install wine
   sudo dpkg --add-architecture i386
   sudo apt-get update
   sudo apt-get install wine32:i386
   ```
8. Reboot your PC
9. Verify WINE was installed by running ```wine --version```
10. Install Microsoft Fonts (and refresh your font cache) with the following code:<br>
    ```
    sudo apt-get install -y ttf-mscorefonts-installer
    fc-cache -f -v
    ```
11. Install all versions of Pipewire with the following command: ```sudo apt-get install -y pipewire pipewire-jack pipewire-alsa pipewire-pulse```
12. Download and configure yabridge with the following commands:<br>
   ```
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
   ```
12. Verify yabridge was installed by running ```yabridgectl --version```.
13. Download the most recent release: https://github.com/Heroin-Bob/AudioTools-for-Linux/releases<br>
    Note: If you want to build the app yourself you can download all the project files then run the <b>Run this to build.sh</b> file and it will build the app for you. You can find the final app in the directory you built the file from by drilling down into <b>bin/Release/net8.0/linux-x64/publish</b>. You do not need any of the other files besides the AudioTools exe file. It is fully self-contained.

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
