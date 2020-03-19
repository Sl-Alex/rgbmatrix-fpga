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
from PIL import Image
from glob import glob
import startup
startup.init()
from vhdl import config

def initialize():
    global spi
    global gpio

    # Configure controller with one CS
    ctrl = SpiController(cs_count=1, turbo=True)

    # ctrl.configure('ftdi:///?')  # Use this if you're not sure which device to use
    # Windows users: make sure you've loaded libusb-win32 using Zadig
    try:
        ctrl.configure(config.FTDI_URL)
    except:
        print("Can't configure FTDI. Possible reasons:")
        print("    1. As a current Linux user you don't have an access to the device.\n"
              "        Solution: https://eblot.github.io/pyftdi/installation.html\n"
              "    2. You use the wrong FTDI URL. Replace FTDI_URL in config.py with one of the following:\n")
        ctrl.configure('ftdi:///?')
        sys.exit(1)

    # Get SPI slave
    # CS0, 10MHz, Mode 0 (CLK is low by default, latch on the rising edge)
    spi = ctrl.get_port(cs=0, freq=10E6, mode=0)

    # Get GPIO
    gpio = ctrl.get_gpio()
    gpio.set_direction(0x10, 0x10)


def send_array(arr):
    # Toggle dat_ncfg pin. This will force internal address counter to zero.
    gpio.write(0x10)
    time.sleep(0.010)
    gpio.write(0x00)
    time.sleep(0.010)
    # Release dat_ncfg pin
    gpio.write(0x10)

    # Synchronous exchange with the remote SPI slave
    spi.exchange(arr, duplex=False)

def send_config(cfg):
    global gpio
    global spi

    # Create a buffer
    write_buf = bytearray(4)
    write_buf[0] = (cfg >> 24) & 0xFF;
    write_buf[1] = (cfg >> 16) & 0xFF;
    write_buf[2] = (cfg >> 8 ) & 0xFF;
    write_buf[3] = cfg & 0xFF;

    # Toggle dat_ncfg pin. This will force internal address counter to zero.
    gpio.write(0x00)
    time.sleep(0.010)
    gpio.write(0x10)
    time.sleep(0.010)
    # Release dat_ncfg pin
    gpio.write(0x00)

    # Synchronous exchange with the remote SPI slave
    spi.exchange(write_buf, duplex=False)

def send_image(im):
    global spi
    global gpio
    im = im.convert('RGB')

    # Create a buffer
    write_buf = bytearray(config.DISP_W * config.DISP_H * config.BPP)

    # Put it to the write buffer
    for y in range(0, config.DISP_H):
        for x in range(0, config.DISP_W):
            r, g, b = im.getpixel((x, y))
            # Convert to the desired bits-per-color
            r = int(r * (2 ** config.BPC) / 256)
            g = int(g * (2 ** config.BPC) / 256)
            b = int(b * (2 ** config.BPC) / 256)
            # Pack into a single word
            packed_word: int = (r << (config.BPC * 2)) | (g << config.BPC) | b
            # Write bytes to the array
            for byte_nr in range(0, config.BPP):
                write_buf[x * config.BPP + y * config.DISP_W * config.BPP + byte_nr] = \
                    (packed_word >> (8 * (config.BPP - 1 - byte_nr))) & 0xFF

    send_array(write_buf)


###

if __name__ == "__main__":
    initialize()
    while True:
        files = sorted(glob('*.gif') + glob('*.png') + glob('*.jpg'))
        for file in files:
            im = Image.open(file)
            send_image(im)
            # time.sleep(0.05)
        time.sleep(1)
    print('Done')
