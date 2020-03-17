#!/usr/bin/env python3

# This script generates a linearization for proper color control.
# LUT table shall be used for "OE" control like this:
#
#if (next_col < COLOR_LUT(to_integer(bpp_count))) then
#    s_oe <= '0';
#else
#    s_oe <= '1';
#end if;
#

import math

# FPGA clock
FPGA_CLOCK = 50000000
# LED matrix clock
LED_CLOCK  = 12500000

# Reset delay, ms
RESET_DELAY = 1000
# Reset length, ms
RESET_LEN   = 100

# Display width
DISP_W = 128
DISP_H = 32
# Color depth (bits per color)
BPC = 4
# Desired gamma
GAMMA = 1.02

# Here you should put your FTDI URL.
# If you have an FTDI cable then probably you can use it in SPI mode.
# You can leave it as it is, script will suggest you to select one of the available devices
FTDI_URL = 'ftdi://ftdi:4232:FTYX7ASG/1'

assert BPC <= 8, "BPC must be <= 8"
assert BPC >  0, "BPC must be > 0"

# Convert ms to clock pulses
RESET_DELAY = int(FPGA_CLOCK * RESET_DELAY / 1000)
# Convert ms to clock pulses
RESET_LEN = int(FPGA_CLOCK * RESET_LEN / 1000)

BPP = math.ceil(BPC * 3/8)

def generate_config_vhd():
    lut_table = '';
    lut_table += '    constant COLOR_LUT: color_lut_t := (0,'
    for i in range(1, 2**BPC):
        comma = ','
        if (i == 2**BPC-1):
            comma = ''

        oe_level = ((i**2)/(2**BPC-1)**2)**GAMMA
        oe_level = round(oe_level*(DISP_W - 1))

        lut_table += str(oe_level) + comma
    lut_table += ');\n';

    print(lut_table)

    file_text = '-- RGB LED Matrix Display Driver for FM6126A-based panels\n'\
    '-- GENERATED AUTOMATICALLY by config.py script\n'\
    '-- \n'\
    '-- Reworked by Oleksii Slabchenko <https://sl-alex.net>\n'\
    '-- Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>\n'\
    '-- This software is distributed under the terms of the MIT License shown below.\n'\
    '-- \n'\
    '-- Permission is hereby granted, free of charge, to any person obtaining a copy\n'\
    '-- of this software and associated documentation files (the "Software"), to\n'\
    '-- deal in the Software without restriction, including without limitation the\n'\
    '-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or\n'\
    '-- sell copies of the Software, and to permit persons to whom the Software is\n'\
    '-- furnished to do so, subject to the following conditions:\n'\
    '-- \n'\
    '-- The above copyright notice and this permission notice shall be included in\n'\
    '-- all copies or substantial portions of the Software.\n'\
    '-- \n'\
    '-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n'\
    '-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n'\
    '-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n'\
    '-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n'\
    '-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING\n'\
    '-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS\n'\
    '-- IN THE SOFTWARE.\n'\
    '\n'\
    'library ieee;\n'\
    'use ieee.math_real.log2;\n'\
    'use ieee.math_real.ceil;\n'\
    '\n'\
    'package rgbmatrix is\n'\
    '\n'\
    '    -- Main constants\n'\
    '    constant PIXEL_DEPTH  : integer  := ' + str(BPC) +   ';        -- number of bits per pixel\n'\
    '    constant FPGA_CLOCK   : integer  := ' + str(FPGA_CLOCK) +   '; -- FPGA clock frequency\n'\
    '    constant LED_CLOCK    : integer  := ' + str(LED_CLOCK) +    '; -- LED panel clock frequency\n'\
    '    constant RESET_DELAY  : integer  := ' + str(RESET_DELAY) +  '; -- reset pulse delay, clock pulses\n'\
    '    constant RESET_LEN    : integer  := ' + str(RESET_LEN) +   ';  -- reset pulse length, clock pulses\n'\
    '    constant PANEL_WIDTH  : integer  := ' + str(DISP_W) +  ';      -- width of the panel in pixels\n'\
    '    constant PANEL_HEIGHT : integer  := ' + str(DISP_H) + ';       -- height of the panel in pixels\n'\
    '    constant CONFIG_WIDTH : positive := 32;       -- two 16-bit registers\n'\
    '    constant CFG1_PRELATCH: positive := 11;       -- Number of "LAT" pulses for CFG1 register write\n'\
    '    constant CFG2_PRELATCH: positive := 12;       -- Number of "LAT" pulses for CFG2 register write\n'\
    '\n'\
    '    -- Derived constants, don\'t change\n'\
    '    constant DATA_WIDTH   : positive := PIXEL_DEPTH*6;\n'\
    '                                         -- one bit for each subpixel (3), times\n'\
    '                                         -- the number of simultaneous lines (2)\n'\
    '    constant INPUT_WIDTH    : positive := ((DATA_WIDTH/2 +7)/8)*8;\n'\
    '    constant ADDR_WIDTH     : positive := positive(log2(real(PANEL_WIDTH*PANEL_HEIGHT/2)));\n'\
    '    constant IMG_WIDTH      : positive := PANEL_WIDTH;\n'\
    '    constant IMG_WIDTH_LOG2 : positive := positive(log2(real(IMG_WIDTH)));\n'\
    '\n'\
    '    type color_lut_t is array (0 to 2**PIXEL_DEPTH-1) of integer;\n' + \
    lut_table + \
    '\n'\
    'end rgbmatrix;'


    f = open("config.vhd","w+")
    f.write(file_text);
    f.close()

if __name__ == "__main__":
    generate_config_vhd()