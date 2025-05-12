
### fix chrome fcitx chinese
### Edit these file:
### /usr/share/applications/com.google.Chrome.desktop
/usr/share/applications/google-chrome.desktop
Append 'Exec = google-chrome-stable' end: -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime


### fix wehchat fcitx chinese
### Edit these file:
/usr/share/applications/wechat.desktop
Append 'Exec =' end: -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime 
