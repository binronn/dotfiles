
# fix chrome fcitx chinese
### Edit these file:
### /usr/share/applications/com.google.Chrome.desktop
/usr/share/applications/google-chrome.desktop
Append 'Exec = google-chrome-stable' end: -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime


# fix wehchat fcitx chinese
### Edit these file:
/usr/share/applications/wechat.desktop
Append 'Exec = ': env 'QT_QPA_PLATFORM=wayland;xcb' QT_SCALE_FACTOR=1.0 GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx 

## 音频问题

sudo pacman -S asla-utils 

# Fix 010editor crash
sudo pacman -S qt5-wayland qt6-wayland
env QT_QPA_PLATFORM=xcb ./010editor
env QT_QPA_PLATFORM=xcb 将这个加到desktop文件中
