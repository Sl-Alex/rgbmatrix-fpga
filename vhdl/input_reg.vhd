-- Simple SPI shift register for LED matrices based on FM6126A.
-- 
-- Copyright (c) 2020 Oleksii Slabchenko <http://sl-alex.net>
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

-- For some great documentation on how the RGB LED panel works, see this page:
-- http://www.rayslogic.com/propeller/Programming/AdafruitRGB/AdafruitRGB.htm
-- or this page
-- http://www.ladyada.net/wiki/tutorials/products/rgbledmatrix/index.html#how_the_matrix_works

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rgbmatrix.all;

entity input_reg is
    port (
        -- SPI inputs
        spi_cs   : in  std_logic;
        spi_clk  : in  std_logic;
        spi_dat  : in std_logic;
        -- Memory outputs
        addr     : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        data     : out std_logic_vector(DATA_WIDTH-1 downto 0);
        dat_lat  : out std_logic
        );
end input_reg;

architecture bhv of input_reg is
    -- Signals
    signal s_bit_count : unsigned(6 downto 0);
    signal s_addr      : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_data      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_dat_lat   : std_logic;
begin
    
    -- Breakout internal signals to the output port
    addr <= s_addr;
    data <= s_data;
    dat_lat <= s_dat_lat;
    
    -- State register
    process(spi_cs, spi_clk, spi_dat, s_bit_count)
    begin
        if(spi_cs = '1') then
            s_bit_count <= (others => '0');
            s_addr <= (others => '0');
            s_data <= (others => '0');
            s_dat_lat <= '0';
        elsif (rising_edge(spi_clk)) then
            s_dat_lat <= '0';
            s_data(DATA_WIDTH-1 downto 1) <= s_data(DATA_WIDTH-2 downto 0);
            s_data(0) <= spi_dat;
            --s_data(DATA_WIDTH - s_bit_count) <= spi_dat;
            s_bit_count <= s_bit_count + 1;
            s_dat_lat <= '0';
            if (s_bit_count = DATA_WIDTH-1) then
                s_bit_count <= (others => '0');
                s_dat_lat <= '1';
                --s_addr <= s_addr + 1;
            end if;
        end if;
    end process;

end bhv;