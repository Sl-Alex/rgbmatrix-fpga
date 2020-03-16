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

# FTDI controller
FTDI_URL = 'ftdi://ftdi:4232:FTYX7ASG/1'

def initialize():
    global spi
    global gpio

    # Configure controller with one CS
    ctrl = SpiController(cs_count=1, turbo=True)

    #ctrl.configure('ftdi:///?')  # Use this if you're not sure which device to use
    # Windows users: make sure you've loaded libusb-win32 using Zadig
    # TODO: Catch an exception and suggest what to do
    ctrl.configure(FTDI_URL)

    # Get SPI slave
    # CS0, 10MHz, Mode 0 (CLK is low by default, latch on the rising edge)
    spi = ctrl.get_port(cs=0, freq=10E6, mode=0)

    # Get GPIO
    gpio = ctrl.get_gpio()
    gpio.set_direction(0x10, 0x10)


def send_image():
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

    # Toggle dat_ncfg pin. This will force internal address counter to zero.
    gpio.write(0x10)
    time.sleep(0.010)
    gpio.write(0x00)
    time.sleep(0.010)
    # Release dat_ncfg pin
    gpio.write(0x10)

    # Synchronous exchange with the remote SPI slave
    spi.exchange(write_buf, duplex=False)

###

startup.init()
initialize()
send_image()

print('Done')
