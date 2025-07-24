#!/bin/bash

# 启动第一个终端：livox激光雷达驱动
{
    gnome-terminal --tab "Livox Driver" -- bash -c "roslaunch livox_ros_driver2 msg_MID360.launch; exec bash"
} &

sleep 5  # 等待驱动初始化

# 启动第二个终端：fast_lio定位
{
    gnome-terminal --tab "Localization" -- bash -c "roslaunch fast_lio_localization localizetion.launch; exec bash"
} &

sleep 8  # 等待定位系统初始化

# 启动第三个终端：发布初始位姿
{
    gnome-terminal --tab "Initial Pose" -- bash -c "rosrun fast_lio_localization publish_initial_pose.py 0 0 0 0 0 0; exec bash"
} &

sleep 3  # 等待初始位姿发布完成

# 启动第四个终端：设置串口权限
{
    gnome-terminal --tab "Serial Permissions" -- bash -c "sudo chmod 777 /dev/ttyS0; exec bash"
} &

sleep 2  # 等待串口权限设置完成

# 启动第五个终端：运行串口发送节点
{
    gnome-terminal --tab "Serial Send" -- bash -c "rosrun my_nav serial_send_pose.py; exec bash"
}

