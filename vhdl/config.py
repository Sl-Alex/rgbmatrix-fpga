#!/usr/bin/env python3

# This script generates a linearization for proper color control.
# LUT table shall be used like this:
#
#if (next_col < COLOR_LUT(to_integer(bpp_count))) then
#    s_oe <= '0';
#else
#    s_oe <= '1';
#end if;
#

# Display width
DISP_W = 128
DISP_H = 32
# Color depth (bits per color)
BPC = 4
# Desired gamma
GAMMA = 1.02

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

    file_text = '-- Adafruit RGB LED Matrix Display Driver\n'\
    '-- User-editable configuration and constants package\n'\
    '-- \n'\
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
    '    \n'\
    '    -- User configurable constants\n'\
    '    constant PIXEL_DEPTH  : integer := ' + str(BPC) + '; -- number of bits per pixel\n'\
    '    \n'\
    '    -- Special constants (change these at your own risk, stuff might break!)\n'\
    '    constant PANEL_WIDTH  : integer := ' + str(DISP_W) + '; -- width of the panel in pixels\n'\
    '    constant PANEL_HEIGHT : integer := ' + str(DISP_H) + '; -- height of the panel in pixels\n'\
    '    constant DATA_WIDTH   : positive := PIXEL_DEPTH*6;\n'\
    '                                         -- one bit for each subpixel (3), times\n'\
    '                                         -- the number of simultaneous lines (2)\n'\
    '    constant INPUT_WIDTH  : positive := ((DATA_WIDTH/2 +7)/8)*8;\n'\
    '\n'\
    '    constant CONFIG_WIDTH : positive := 32;\n'\
    '    \n'\
    '    -- Derived constants\n'\
    '    constant ADDR_WIDTH     : positive := positive(log2(real(PANEL_WIDTH*PANEL_HEIGHT/2)));\n'\
    '    constant IMG_WIDTH      : positive := PANEL_WIDTH;\n'\
    '    constant IMG_WIDTH_LOG2 : positive := positive(log2(real(IMG_WIDTH)));\n'\
    '    constant CFG1_PRELATCH  : positive := 11;\n'\
    '    constant CFG2_PRELATCH  : positive := 12;\n'\
    '\n'\
    '    type color_lut_t is array (0 to 2**PIXEL_DEPTH-1) of positive;\n' + \
    lut_table + \
    '\n'\
    'end rgbmatrix;'


    f = open("config.vhd","w+")
    f.write(file_text);
    f.close()

if __name__ == "__main__":
    generate_config_vhd()