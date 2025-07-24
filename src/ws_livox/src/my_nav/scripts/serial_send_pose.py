#!/usr/bin/env python3
import rospy
import serial
import struct
import math
import tf.transformations as tf_trans
from nav_msgs.msg import Odometry

class LocalizationToSerial:
    def __init__(self):
        rospy.init_node('localization_to_serial_node', anonymous=True)
        self.ser = serial.Serial('/dev/ttyS0', 115200, timeout=1)
        rospy.Subscriber('/localization', Odometry, self.pose_callback, queue_size=1)

    def pose_callback(self, msg):
        pos = msg.pose.pose.position
        ori = msg.pose.pose.orientation

        q = [ori.x, ori.y, ori.z, ori.w]
        roll, pitch, yaw = tf_trans.euler_from_quaternion(q)

        # 乘 100 后四舍五入为 16-bit 整数
        x = int(round(pos.x * 100))
        y = int(round(pos.y * 100))
        z = int(round(pos.z * 100))
        r = int(round(math.degrees(roll)  * 100))
        p = int(round(math.degrees(pitch) * 100))
        yw = int(round(math.degrees(yaw)  * 100))

        data = (
            struct.pack('<B', 0xff) +
            struct.pack('<B', 0xfe) +
            struct.pack('<h', x) +
            struct.pack('<h', y) +
            struct.pack('<h', z) +
            struct.pack('<h', r) +
            struct.pack('<h', p) +
            struct.pack('<h', yw) +
            struct.pack('<B', 0xfd)
        )
        try:
            self.ser.write(data)
            rospy.loginfo_throttle(1, f"Sent: x={x} y={y} yaw={yw}")
        except serial.SerialException as e:
            rospy.logwarn(f"Serial write failed: {e}")

    def spin(self):
        rospy.loginfo("localization_to_serial_node running ...")
        rospy.spin()

if __name__ == '__main__':
    try:
        node = LocalizationToSerial()
        node.spin()
    except rospy.ROSInterruptException:
        pass

