-- RGB LED Matrix Display Driver for FM6126A-based panels
-- Special memory for the framebuffer with separate read/write clocks
-- 
-- Reworked by Oleksii Slabchenko <https://sl-alex.net> 
-- Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
-- This software is distributed under the terms of the MIT License shown below.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

-- For more information on how to infer RAMs on Altera devices see this page:
-- http://quartushelp.altera.com/current/mergedProjects/hdl/vhdl/vhdl_pro_ram_inferred.htm

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.rgbmatrix.all;

entity memory is
    port (
        clk_wr  : in  std_logic;
        input   : in  std_logic_vector(DATA_WIDTH/2-1 downto 0);
        clk_rd  : in  std_logic;
        addr_wr : in  std_logic_vector(ADDR_WIDTH downto 0);
        addr_rd : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        output  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end memory;

architecture bhv of memory is
    -- Inferred RAM storage signal
    type ram is array(2**ADDR_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH/2-1 downto 0);
    signal ram_block_up, ram_block_lo : ram;
begin
    
    -- Write process for the memory
    process(clk_wr, addr_wr)
    begin
        if(rising_edge(clk_wr)) then
            if (conv_integer(addr_wr) < 2**ADDR_WIDTH) then
                ram_block_up(conv_integer(addr_wr)) <= input; -- store input at the current write address
            else
                ram_block_lo(conv_integer(addr_wr) - 2**ADDR_WIDTH) <= input; -- store input at the current write address
            end if;
        end if;
    end process;
    
    -- Read process for the memory
    process(clk_rd)
    begin
        if(rising_edge(clk_rd)) then
            output(DATA_WIDTH-1 downto DATA_WIDTH/2) <= ram_block_up(conv_integer(addr_rd)); -- retrieve contents at the given read address
            output(DATA_WIDTH/2-1 downto 0) <= ram_block_lo(conv_integer(addr_rd)); -- retrieve contents at the given read address
        end if;
    end process;

end bhv;
