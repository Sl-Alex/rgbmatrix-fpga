-- Adafruit RGB LED Matrix Display Driver
-- Testbench for simulation of the LED matrix finite state machine
-- 
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

library ieee;
use ieee.std_logic_1164.all;

use work.rgbmatrix.all;

entity input_reg_tb is
end input_reg_tb;

architecture tb of input_reg_tb is
    constant clk_period : time := 20 ns; -- for a 50MHz clock
    constant num_cycles : positive := 10; -- change this to your liking

    -- Input signals
    signal clk      : std_logic;
    signal spi_cs   : std_logic;
    signal spi_clk  : std_logic;
    signal spi_dat  : std_logic;
    -- Output signals
    signal dat_lat  : std_logic;
    signal addr     : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data     : std_logic_vector(DATA_WIDTH/2-1 downto 0);
begin
    
    -- Instantiate the Unit Under Test (UUT)
    UUT : entity work.input_reg
        port map (
            clk_in   => clk,
            spi_cs   => spi_cs,
            spi_clk  => spi_clk,
            spi_dat  => spi_dat,
            dat_lat  => dat_lat,
            addr     => addr,
            data     => data
        );
    
    -- Clock process
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    process
    begin
        -- Perform the simulation
        spi_clk <= '0';
        spi_dat <= '0';
        spi_cs  <= '1';
        wait for clk_period*num_cycles;
        spi_cs <= '0';

        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';





        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';
        ----
        spi_dat <= '0';
        wait for clk_period*num_cycles;
        spi_clk <= '1';
        wait for clk_period*num_cycles;
        spi_clk <= '0';



        
        wait for clk_period*num_cycles;
        spi_cs <= '1';
        -- Wait forever
        wait for 1 us;
        assert false report "simulation ended" severity failure;

    end process;
    
end tb;
