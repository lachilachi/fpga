'''
Author: He
Date: 2022-02-12 12:31:28
LastEditTime: 2022-02-14 15:12:43
Description: video publish
'''

import cv2
from socket import *
ddsip='127.0.0.1'
addr = (ddsip, 8081)
cap = cv2.VideoCapture('test.mp4')
#设置视频窗口大小
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
udpsocket = socket(AF_INET, SOCK_DGRAM)
while True:
    success, img = cap.read()
    result, buff_data = cv2.imencode('.jpg', img, [cv2.IMWRITE_JPEG_QUALITY, 50])
    udpsocket.sendto(buff_data, addr)
    print(f'Send Data Size:{img.size} Byte')
    cv2.putText(img, "publish", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
    cv2.imshow('publish', img)
    if cv2.waitKey(1) & 0xFF == ord('x'):
        break

udpsocket.close()
cv2.destroyAllWindows()

