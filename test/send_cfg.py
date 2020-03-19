#!/usr/bin/env python3

# Script updates FM6126A configuration registers.

import startup
startup.init()
from vhdl import config
import spi_io

###

spi_io.initialize()
cfg1 = 0b0111000000000000
cfg2 = 0b0000000001000000
spi_io.send_config((cfg1 << 16) | cfg2)
print('Done')
