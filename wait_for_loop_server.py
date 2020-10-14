#!/usr/bin/env python
import rospy
import time

if __name__ == "__main__":
    rospy.init_node("WaitServer")

    rospy.wait_for_service('/swarm_loop/hfnet')

    print("HF-Net service ready.")

    # rospy.wait_for_service('/swarm_loop/superpoint')
    # print("Superpoint service ready.")

