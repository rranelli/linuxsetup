# ref: http://www.noobslab.com/2014/04/macbuntu-1404-pack-is-released.html
# Adding repositories
# sudo add-apt-repository ppa:docky-core/ppa
# sudo add-apt-repository ppa:noobslab/themes
# sudo add-apt-repository ppa:noobslab/apps

# sudo apt-get update

# 1. Mac OSX Wallpaper
# http://drive.noobslab.com/data/Mac-13.10/MBuntu-Wallpapers.zip

# 2. Docky
# sudo apt-get install -y  docky

# 3. MACOSX Lion theme, icons and cursors
sudo apt-get install -y  mac-ithemes-v3
sudo apt-get install -y  mac-icons-v3

# 4. Apply MUbuntu Splash
sudo apt-get install -y  mbuntu-bscreen-v3

# 5. Install MacBundu theme for lightdm
sudo apt-get install -y  mbuntu-lightdm-v3

# 6. Indicador Synapse
sudo apt-get install -y  indicator-synapse

# 7. Replace 'Ubuntu Desktop' text with 'Mac' on the Panel
gsettings set com.canonical.desktop.interface scrollbar-mode normal

# 8. Replace Overlay Scroll-bars with Normal
cd && wget -O Mac.po http://drive.noobslab.com/data/Mac-14.04/change-name-on-panel/mac.po
cd /usr/share/locale/en/LC_MESSAGES; sudo msgfmt -o unity.mo ~/Mac.po;rm ~/Mac.po;cd

# 9. Remove White Dots and Ubuntu Logo from Lock Screen:
sudo xhost +SI:localuser:lightdm
# Run this manually
#sudo su lightdm -s /bin/bash
#gsettings set com.canonical.unity-greeter draw-grid false;exit
sudo mv /usr/share/unity-greeter/logo.png /usr/share/unity-greeter/logo.png.backup

# 10. Apple Logo in Launcher
wget -O launcher_bfb.png http://drive.noobslab.com/data/Mac-14.04/launcher-logo/apple/launcher_bfb.png
sudo mv launcher_bfb.png /usr/share/unity/icons/

# 11. Auto-hide Unity Launcher:
sudo apt-get install -y  unity-tweak-tool

# 12. Unity Tweak Tool to change Themes & Icons:
sudo apt-get install -y  libreoffice-style-sifr

# 13. Install Monochrome icons for Libreoffice:
wget -O mac-fonts.zip http://drive.noobslab.com/data/Mac-14.04/macfonts.zip
sudo unzip mac-fonts.zip -d /usr/share/fonts; rm mac-fonts.zip
sudo fc-cache -f -v

# 14. (Optional) Mac fonts:
wget -O mac-fonts.zip http://drive.noobslab.com/data/Mac-14.04/macfonts.zip
sudo unzip mac-fonts.zip -d /usr/share/fonts; rm mac-fonts.zip
sudo fc-cache -f -v
