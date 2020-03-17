#!/usr/bin/env python3

import time
import sys
from shutil import copyfile
import startup
startup.init()
from vhdl import config
import spi_io

import mss
from PIL import Image, ImageFilter

monitor = -1
if len(sys.argv) > 1:
    try:
        monitor = int(sys.argv[1])
    except:
        print("Command line parameter not recognized")
        exit()

sct = mss.mss()
while True:
    if (monitor < 0) or (monitor > len(sct.monitors) - 1):
        print("Monitor not specified, choose in range 0 to " + str(len(sct.monitors) - 1))
    else:
        break;

    monitors = len(sct.monitors)
    if monitors > 1:
        for i in range(0, monitors):
            print("Monitor "+str(i)+": "+ str(sct.monitors[i]))

    try:
        monitor = int(input("Choose monitor to capture: "))
    except:
        print("Input not recognized, interrupting")
        exit()

print("Monitor " + str(monitor) + " selected")
mon = sct.monitors[monitor]
width  = mon["width"]
height = mon["height"]
print("Size: " + str(width) + "x" + str(height))

if width/height > config.DISP_W/config.DISP_H:
    # Use the whole height and calculate a proportional width
    capt_height = height
    capt_width = height * config.DISP_W / config.DISP_H
    capt_left = (width - capt_width) / 2
    capt_top = 0
else:
    # Use the whole width and calculate a proportional height
    capt_width = width
    capt_height = width * config.DISP_H / config.DISP_W
    capt_left = 0
    capt_top = (height - capt_height) / 2

# Round all values
capt_width = round(capt_width)
capt_height = round(capt_height)
capt_left = round(capt_left)
capt_top = round(capt_top)
print("capt_width = " + str(capt_width) + ", capt_height = " + str(capt_height))

# The screen part to capture
mon_cap = {
    "top": mon["top"] + capt_top,
    "left": mon["left"] + capt_left,
    "width": capt_width,
    "height": capt_height,
    "mon": monitor,
}
output = "sct-mon{mon}_{top}x{left}_{width}x{height}.png".format(**mon_cap)

spi_io.initialize()

tstart = time.time()
cnt=0

print("Press Ctrl+C to stop")

try:
    while True:
        # Grab the data
        sct_img = sct.grab(mon_cap)
        img = Image.frombytes("RGB", sct_img.size, sct_img.bgra, "raw", "BGRX")
        img = img.resize((config.DISP_W, config.DISP_H), Image.BICUBIC)
        img = img.filter(ImageFilter.SHARPEN)
        # Send over SPI
        spi_io.send_image(img)
        cnt += 1
except KeyboardInterrupt:
    pass

tend = time.time();
if tstart != tend:
    print("average fps = " + str(cnt/(tend - tstart)))
