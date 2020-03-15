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
use ieee.math_real.log2;

use work.rgbmatrix.all;

entity reset_generator is
    generic (
            RST_DELAY : integer;
            RST_LEN   : integer
        );
    port (
        -- System clock
        clk_in   : in std_logic;
        -- Reset output
        rst_out  : out std_logic
        );
end reset_generator;

architecture bhv of reset_generator is
    -- Signals
    signal counter_delay: unsigned(positive(log2(real(RST_DELAY))) downto 0) := (others => '0');
    signal counter_len: unsigned(positive(log2(real(RST_LEN))) downto 0) := (others => '0');
    signal s_rst_out: std_logic := '0';
begin

    -- Breakout internal signals to the output port
    rst_out <= s_rst_out;

    -- Delay line
    process(clk_in)
    begin
        if (rising_edge(clk_in)) then
            s_rst_out <= '0';
            if (counter_delay < RST_DELAY) then
                counter_delay <= counter_delay + "1";
            else
                if (counter_len < RST_LEN) then
                    s_rst_out <= '1';
                    counter_len <= counter_len + "1";
                end if;
            end if;
        end if;
    end process;

end bhv;