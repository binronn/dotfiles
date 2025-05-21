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

# 函数：检查指定显示器是否启用
is_monitor_enabled() {
    local monitor_name="$1"
    
    # 使用 hyprctl monitors -j 获取所有连接显示器的JSON数据
    # 然后用 jq 过滤出指定名称的显示器，并检查其 'active' 字段
    # 'active' 字段为 true 表示显示器当前正在显示内容
    # 'disabled' 字段为 false 表示显示器没有被明确设置为禁用
    
    # 假设如果显示器在列表中且没有被显式禁用，就认为是启用的
    # 注意：如果显示器根本没有连接，它也不会出现在输出中
    
    if hyprctl monitors -j | jq -e ".[] | select(.name == \"$monitor_name\" and .active == true and .disabled == false)" > /dev/null; then
        return 0 # 返回 0 表示 true (已启用)
    else
        return 1 # 返回 1 表示 false (未启用或未连接)
    fi
}

# 检查 DP-3 是否存在于连接的显示器列表中
if echo "$CONNECTED_MONITORS" | grep -q "$EXTERNAL_MONITOR"; then
    # 禁用主显示器
    hyprctl keyword monitor "$MAIN_MONITOR,disable"

	hyprctl keyword monitor "$EXTERNAL_MONITOR,$EXTERNAL_MONITOR_CONFIG"
	echo 'Xft.dpi:0' | xrdb -merge -

else
    # 启用主显示器，并应用其默认配置
    # hyprctl keyword monitor "$MAIN_MONITOR,$MAIN_MONITOR_CONFIG"
	echo 'Xft.dpi:145' | xrdb -merge -
fi

# 重新加载 Hyprland 配置以确保更改生效（可选，但推荐）
# hyprctl reload
