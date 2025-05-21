#!/bin/bash

# 定义主显示器和外部显示器的名称
MAIN_MONITOR="eDP-1"
EXTERNAL_MONITOR="DP-3"

# 主显示器的默认配置（在外部显示器断开时使用）
# 请根据你的实际情况修改分辨率、位置和缩放
MAIN_MONITOR_CONFIG="preferred,0x0,1.6000000" # 示例：分辨率@刷新率,位置,缩放
EXTERNAL_MONITOR_CONFIG="2560x14440@74,0x-1440,1" # 示例：分辨率@刷新率,位置,缩放

# 获取当前连接的显示器列表
CONNECTED_MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

# 检查 DP-3 是否存在于连接的显示器列表中
if echo "$CONNECTED_MONITORS" | grep -q "$EXTERNAL_MONITOR"; then
    echo "DP-3 is connected. Disabling $MAIN_MONITOR."
    # 禁用主显示器
    hyprctl keyword monitor "$MAIN_MONITOR,disable"
else
    echo "DP-3 is not connected. Enabling $MAIN_MONITOR."
    # 启用主显示器，并应用其默认配置
    hyprctl keyword monitor "$MAIN_MONITOR,$MAIN_MONITOR_CONFIG"
fi

# 重新加载 Hyprland 配置以确保更改生效（可选，但推荐）
# hyprctl reload
