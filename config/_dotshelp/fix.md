
## 音频问题
sudo pacman -S asla-utils 

# Fix 010editor crash
sudo pacman -S qt5-wayland qt6-wayland
env QT_QPA_PLATFORM=xcb ./010editor
env QT_QPA_PLATFORM=xcb 将这个加到desktop文件中
