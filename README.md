#   前言
最近实验室购入了mid360激光雷达，用于给我们学习研究并用于比赛，在经过一段时间的摸索后，终于配通了整个雷达的驱动，并进行定位及导航，于是便想写一篇文章来记录中途出现的问题以及解决步骤。

在学习之初，我用的教程来自这个博主的文章：[使用mid360从0开始搭建实物机器人入门级导航系统，基于Fast_Lio,Move_Base](https://blog.csdn.net/weixin_52612260/article/details/134124028?spm=1001.2014.3001.5506)


板卡：rk3588
环境：ubuntu20.04+Noetic

注意：因为我的板卡性能并不是很够，所以我关闭了点云数据在rviz的显示，也可以采用ros分布式通信，在从机上打开rviz,这样不会这么卡

开始配置之前，可以先克隆一下我的工作空间，这样对比着配置：[MID360_fast_lio](https://github.com/tudou11261126/MID360_fast_lio.git)
#   (一）运行mid360
##  （1）硬件连接
首先将mid360的一分三航空线的网线插口插入板卡的网口中，然后给mid360上电。
点击左上角对Ubuntu设置进行修改，设置ip地址，设置手动静态地址IP：192.168.1.50，子网掩码：255.255.255.0，网关：192.168.1.1。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1baadcdfaf01476cb2c8eb01597ef176.png#pic_center)
##  （2）安装并运行Livox-SDK2
###  2.1  在任意目录新建一个工作空间
```bash
mkdir livox_ws
cd livox_ws
mkdir src
```
###  2.2  安装 Livox-SDK2
####  2.2.1 安装CMake

```bash
sudo apt install cmake
```
####  2.2.2 编译并安装Livox-SDK2

```bash
mkdir 3rd_party
cd 3rd_party
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd ./Livox-SDK2/
mkdir build
cd build
cmake .. && make 
sudo make install
```
####  2.2.3  修改mid360_config.json
进入**livox_ws/3rd_party/Livox-SDK2/samples/livox_lidar_quick_start**这个文件夹，找到mid360_config.json，把 host_ip 改成 192.168.1.50
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d6ebed9be78544f280e58ad282b95682.png#pic_center)

###  2.3  运行Livox-SDK2示例
进入**livox_ws/3rd_party/Livox-SDK2/build/samples/livox_lidar_quick_start**这个文件夹打开终端，运行如下代码

```bash
./livox_lidar_quick_start ../../../samples/livox_lidar_quick_start/mid360_config.json
```
（提醒！！！看好路径，这和上一个改ip的不是同一个文件夹）
运行成功会显示以下画面，然后会有数据流一直发（如果不是这个的话可能IP错了)，注意要保持雷达的连接，要不会显示雷达初始化错误
成功：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1eb91e78b22940ac9d2b51bfa428fc58.png#pic_center)
失败：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6e3359a5a54e4a5ca5f1317705c45671.png#pic_center)

## （3）安装并运行livox_ros_driver2
### 3.1  下载驱动

```bash
cd src
git clone https://github.com/Livox-SDK/livox_ros_driver2.git ws_livox/src/livox_ros_driver2
```
### 3.2  驱动代码
进入**livox_ws/src/ws_livox/src/livox_ros_driver2**文件夹，编译驱动代码

```bash
./build.sh ROS1
```
### 3.3  更改json文件
进入config文件夹，找到**MID360_config.json**文件，把里面的host_net_info的四个IP地址改成192.168.1.50，然后lidar_configs里面的IP地址改成      192.168.1.1xx，xx为你的mid360序列号的最后两位(我的是49），所以改为192.168.1.149
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4459f1ea27a24395b81d15f639589bac.png#pic_center)

### 3.4  运行驱动

```bash
source ../../devel/setup.bash           
roslaunch livox_ros_driver2 msg_MID360.launch
roslaunch livox_ros_driver2 rviz_MID360.launch
```
 可以自己去.bashrc里source,这样下次直接打开终端就行了
 运行完成后观察rviz，此时应该出现点云图，如果没有，证明前面有地方配置出错了，重新来一遍
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/87eeea2dd3004c999ac8597be2114f96.png#pic_center)

#  （二）运行fast_lio
##  （1）  下载fast_lio源码
我把fast_lio放在与livox_ros_driver2放在同一个src文件夹下，之前放在别的工作空间下时出现了些问题，在下载fast_lio之前先安装eigen库和PCL库

```bash
sudo apt-get install  libeigen3-dev
sudo apt-get install  libpcl-dev
git clone https://github.com/hku-mars/FAST_LIO.git
```
## （2）  修改文件
建议用vscode打开FAST_LIO，用ctrl+f搜索，把全部livox_ros_driver都改成livox_ros_driver2，否则无法编译通过
	（1）修改FAST_LIO/CMakelists.txt
	（2）修改FAST_LIO/package.xml
	（3）修改FAST_LIO/src/preprocess.h		
	（4）修改FAST_LIO/src/preprocess.cpp		 
	（5）修改FAST_LIO/src/laserMapping.cpp	
把以上文件中的livox_ros_driver都改成livox_ros_driver2
## （3）  编译fast_lio

```bash
cd FAST_LIO
git submodule update --init
cd ../..
catkin_make
```
## （4）  安装sophus

```bash
git clone https://github.com/strasdat/Sophus.git
cd Sophus
git checkout a621ff
mkdir build
cd build
cmake ../ -DUSE_BASIC_LOGGING=ON
make
sudo make install
```
这里大概率会报错
<img width="576" height="378" alt="image" src="https://github.com/user-attachments/assets/a80b9890-e184-4a82-af40-fbb125df5802" />

打开so2.cpp
修改为

```bash
SO2::SO2()
{
  unit_complex_.real(1.);
  unit_complex_.imag(0.);
}
```

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8ff46c6022354770ab27e1b1efa18bef.png#pic_center)

安装完成后重新编译一次fast_lio所在的工作空间
##  （5）运行fast_lio

```bash
roslaunch livox_ros_driver2 msg_MID360.launch
roslaunch fast_lio mapping_mid360.launch
```
没报错就运行成功了
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5febba6f25764508b63626a79f8fde61.png#pic_center)
运行完关掉终端，刚刚建的三维地图会自动保存在FAST_LIO/PCD文件夹里
#  （三）  安装fast_lio_localiztion重定位
## （1）  配置环境
安装之前，我们要先安装所需的环境，可以看一下原仓库[FAST_LIO_LOCALIZATION](https://github.com/davidakhihiero/FAST_LIO_LOCALIZATION-ROS-NOETIC)
```bash
sudo apt install ros-$ROS_DISTRO-ros-numpy
pip install numpy==1.21
pip install open3d
```
## （2）  安装源码编译
继续放在ws_livox/src下
```bash
git clone https://github.com/HViktorTsoi/FAST_LIO_LOCALIZATION.git
cd FAST_LIO_LOCALIZATION
git submodule update --init
cd ../..
catkin_make
```
这里和fast_lio是一样的，你需要修改文件，把全部livox_ros_driver都改成livox_ros_driver2，否则无法编译通过
如果出现以下报错，证明没修改完livox_ros_driver
![fast_lio](https://i-blog.csdnimg.cn/direct/5aea81d4e95a44b48a1c8a33ec4ef885.png#pic_center)
如果出现这个错误，是因为这个fast_lio_localization中的fastlio_mapping与fast_lio中重复了，按照下图把fastlio_mapping改成**fastlio_mapping1**就可以了
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b44871625c27426a8aebae8a96dccaca.png#pic_center)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e2c8f01549e94e74ac83d2f2bd72e730.png#pic_center)
做完这些再**catkin_make**就可以成功编译了
## （3）  修改文件
因为在fast_lio_localization仓库克隆下来的代码是python2写的，我们需要进到
fast_lio_localization/scripts下，将三个py文件进行修改，使其能够正常运行，因为我们的环境是python3的，有些库名也改变了
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9284d706d4d240c08d8db4cfc855d8de.png#pic_center)
可以直接复制我的三个文件，覆盖掉原来的三个**python文件**，然后再从fast_lio_localization/config,复制**mid360.yaml**进到你自己的config文件夹里，最后再从fast_lio_localization/launch中复制**localization_MID360.launch**放进你自己的launch文件夹里。
## （4）  运行重定位
```bash
roslaunch livox_ros_driver2 msg_MID360.launch
roslaunch fast_lio_localization localization_MID360.launch 
rosrun fast_lio_localization publish_initial_pose.py 0 0 0 0 0 0
# 这里的原点是你建图时候的起点。
```
运行完后可以用rostopic echo /localizetion查看到雷达的位置变化信息
