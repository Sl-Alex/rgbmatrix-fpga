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

entity delay_line is
    generic (
            DELAY_LEN  : integer
        );
    port (
        -- System clock
        clk_in   : in std_logic;
        -- System clock
        rst      : in std_logic;
        -- Data IO
        data_in  : in  std_logic;
        data_out : out std_logic
        );
end delay_line;

architecture bhv of delay_line is
    -- Signals
    signal s_data      : std_logic_vector(DELAY_LEN - 1 downto 0);
begin

    -- Breakout internal signals to the output port
    data_out <= s_data(DELAY_LEN-1);

    -- Delay line
    process(rst, clk_in, data_in)
    begin
        if(rst = '1') then
            s_data <= (others => '0');
        elsif (rising_edge(clk_in)) then
            s_data(DELAY_LEN - 1 downto 1) <= s_data(DELAY_LEN - 2 downto 0);
            s_data(0) <= data_in;
        end if;
    end process;

end bhv;