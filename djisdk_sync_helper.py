#!/usr/bin/env python
import rospy
import time
from dji_sdk.srv import SetHardSync

if __name__ == "__main__":
    print("Start DJI_SDK Sync Helper")

    rospy.wait_for_service('/dji_sdk_1/dji_sdk/set_hardsyc')
    call_hardsyc = rospy.ServiceProxy('/dji_sdk_1/dji_sdk/set_hardsyc', SetHardSync)
    
    ret = 0
    while ret == 0:
        ret = call_hardsyc(20, 0)
        time.sleep(0.1)
    
    print("Successful called hardsyc...exiting helper")