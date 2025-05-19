
初步检查音频服务器状态 (pactl list sinks)：
    输出显示： 只有一个 "Dummy Output" (虚拟输出) 设备。
    诊断： PipeWire (或其 PulseAudio 兼容层) 没有检测到您的实际声卡输出设备。音频信号被发送到了一个虚拟设备，所以没有声音。

检查底层 ALSA 状态 (cat /proc/asound/cards)：
    输出显示： 文件内容为空。
    诊断： 这是关键发现。/proc/asound/cards 显示 ALSA 子系统检测到的声卡。文件为空意味着内核的 ALSA 驱动没有成功识别和初始化声卡硬件。问题在于比 PipeWire 更低的层次。

检查硬件检测 (lspci)：
    命令： lspci -v | grep -i audio
    输出显示： 检测到了您的 Intel Meteor Lake-P HD Audio Controller 硬件，并且内核加载了 sof-audio-pci-intel-mtl 驱动。
    诊断： 声卡硬件被检测到，驱动模块也加载了。问题不在于硬件物理存在或基础驱动模块缺失，而在于驱动初始化或与硬件交互时出了问题，导致 ALSA 未能完全识别声卡。对于 SOF (Sound Open Firmware) 驱动，这通常是固件问题。

检查内核错误日志 (dmesg)：
    命令： sudo dmesg | grep -i error (也检查了 grep -i sof 等相关日志)
    输出显示： 发现了错误 sof-audio-pci-intel-mtl ... error: sof_probe_work failed err: -2。
    诊断： 错误码 -2 (ENOENT) 强烈表明 SOF 驱动未能找到所需的固件文件来完成初始化。这是导致 ALSA 未能完全识别声卡的主要原因。

安装 Sound Open Firmware (sof-firmware)：
    命令： sudo pacman -S sof-firmware
    过程： sof-firmware 包本身安装成功，但在安装后的 initramfs 更新阶段出现了指向不存在的 vmlinuz-linux 内核的错误。
    诊断： sof-firmware 包已成功将所需的固件文件放置到 /lib/firmware/ 目录中。initramfs 的错误是系统配置问题，与固件安装本身无关。

重启系统：
    操作： 重启电脑。
    效果： 重启后，内核能够加载新安装的 SOF 固件文件，并成功初始化声卡驱动。
    验证： 再次检查 cat /proc/asound/cards，现在应该能看到您的声卡设备了。pactl list sinks 也会显示您的实际声卡输出设备（不再只有 Dummy Output），并且在 pavucontrol 中可以看到您的设备。

检查 ALSA 混音器 (alsamixer)： from sudo pacman -S alsa-utils
    问题： 尽管声卡被检测到且在 pavucontrol 中可见，但播放音频时仍然没有声音。pavucontrol 显示音量和设置正常。
    诊断： 这表明音频信号从 PipeWire 发送到了 ALSA 设备，但在 ALSA 层面的某个地方（通常是混音器通道）被静音或音量过低，导致无法到达物理扬声器。pavucontrol 不完全控制或显示所有 ALSA 混音器通道。
    操作： 安装 alsa-utils 包以获取 alsamixer 工具 (sudo pacman -S alsa-utils)。运行 alsamixer，按 F6 选择您的声卡，并使用左右箭头仔细检查所有通道（特别是 Master, Speaker, Headphone, PCM 以及其他输出相关的通道），寻找 MM (静音) 标记，并使用 M 键解除静音，使用上下箭头调整音量。
    操作： 使用 sudo alsactl store 保存 ALSA 设置。

使用 aplay 或 speaker-test 直接测试 ALSA 输出：
    命令： aplay -D hw:CARD=0,DEV=0 /usr/share/sounds/alsa/Front_Center.wav 或 speaker-test -c 2 -t wav -D hw:CARD=0,DEV=0 (使用您的声卡设备名)。
    目的： 绕过 PipeWire，直接通过 ALSA 测试声卡是否能发出声音，以隔离问题。
    结果： 在您检查并调整 alsamixer 后，执行这个测试（或后续的常规播放）可能就已经恢复了声音。



使用 alsamixer 检查 ALSA：
    F6 切换声卡
    打开终端并运行 alsamixer。
    确保 "Master"、"PCM"、"Speaker"（或其他相关的输出通道）没有被静音 (MM)。如果被静音，按 M 键解除静音。
    使用上下箭头调整音量到合适的水平。
    按 Esc 退出。
