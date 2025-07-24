#!/bin/bash

# 自动执行第一个命令：启动LiDAR驱动
{
    gnome-terminal --tab "LiDAR Driver" -- bash -c "roslaunch livox_ros_driver2 msg_MID360.launch; exec bash"
} &

sleep 5  # 等待驱动初始化完成

# 自动执行第二个命令：启动建图
{
    gnome-terminal --tab "Mapping" -- bash -c "roslaunch fast_lio_localization build_map.launch; exec bash"
} &

sleep 10  # 等待建图系统初始化完成

# 第三个命令需要手动确认后执行
{
    SAVE_CMD="rosrun map_server map_saver map:=/projected_map -f ~/Desktop/livox_ws/src/ws_livox/src/FAST_LIO/PCD/scans"
    gnome-terminal --tab "Save Map" -- bash -c "echo '地图构建完成后，按Enter键保存地图'; echo; echo '执行命令: $SAVE_CMD'; read; $SAVE_CMD; echo '地图已保存！'; exec bash"
}

