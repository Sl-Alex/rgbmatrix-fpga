#!/usr/bin/env python3

# Script outputs all images *.gif,*.png,*.jpg from its folder
# with some delay. Image size should match the display size.
#
# Requirements:
# 1. PyFTDI, installation details see this link:
#    https://eblot.github.io/pyftdi/installation.html
# 2. Pillow

import time
from pyftdi.spi import SpiController
import startup
startup.init()

import config
import spi_io

# FTDI controller

def send_test():
    global gpio
    global spi

    # Create a buffer
    write_buf = bytearray(config.DISP_W*config.DISP_H*config.BPP)

    for y in range(0, config.DISP_H):
        r=0;g=0;b=0;
        for x in range(0, config.DISP_W):
            # Convert to desired BPC
            if (int(x/(2**config.BPC))%3)==0:
                r=x%(2**config.BPC);g=0;b=0;
            if (int(x/(2**config.BPC))%3)==1:
                r=0;g=x%(2**config.BPC);b=0;
            if (int(x/(2**config.BPC))%3)==2:
                r=0;g=0;b=x%(2**config.BPC);
            # Pack into a single word
            packed_word: int = (r << (config.BPC*2)) | (g << config.BPC) | b
            # Write bytes to the array
            for byte_nr in range(0, config.BPP):
                write_buf[x*config.BPP + y*config.DISP_W*config.BPP + byte_nr] = \
                    (packed_word >> (8 * (config.BPP - 1 - byte_nr))) & 0xFF 

    spi_io.send_array(write_buf)


###

spi_io.initialize()
send_test()

print('Done')
