
# fix chrome fcitx chinese
### Edit these file:
### /usr/share/applications/com.google.Chrome.desktop
/usr/share/applications/google-chrome.desktop
Append 'Exec = google-chrome-stable' end: -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime


# fix wehchat fcitx chinese
### Edit these file:
/usr/share/applications/wechat.desktop
Append 'Exec = ': env 'QT_QPA_PLATFORM=wayland;xcb' QT_SCALE_FACTOR=1.0 GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx 

