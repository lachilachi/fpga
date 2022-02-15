'''
Author: He
Date: 2022-02-12 12:31:28
LastEditTime: 2022-02-14 15:12:43
Description: video subscribe
'''

import numpy as np
import cv2
from socket import *

udpsocket = socket(AF_INET, SOCK_DGRAM)
addr = ('0.0.0.0', 8081)
udpsocket.bind(addr)
udpsocket.setblocking(0)

while True:
    data = None
    try:
        data, saddr = udpsocket.recvfrom(921600)
        buff_data = np.frombuffer(data, dtype='uint8')
        video_img = cv2.imdecode(buff_data, 1)
        cv2.putText(video_img, "subscribe", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
        cv2.imshow('subscribe', video_img)
    except BlockingIOError as e:
        pass
    if cv2.waitKey(1) & 0xFF == ord('x'):
        break

cv2.destroyAllWindows()

