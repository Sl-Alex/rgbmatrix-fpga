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
    signal dat_ncfg : std_logic;
    -- Output signals
    signal addr     : std_logic_vector(ADDR_WIDTH downto 0);
    signal data     : std_logic_vector(DATA_WIDTH/2-1 downto 0);
    signal dat_lat  : std_logic;
    signal cfg      : std_logic_vector(CONFIG_WIDTH-1 downto 0);
    signal cfg_lat  : std_logic;

    signal dat_test : std_logic_vector(INPUT_WIDTH-1 downto 0);
    signal cfg_test : std_logic_vector(CONFIG_WIDTH-1 downto 0);
begin
    
    -- Instantiate the Unit Under Test (UUT)
    UUT : entity work.input_reg
        port map (
            clk_in   => clk,
            spi_cs   => spi_cs,
            spi_clk  => spi_clk,
            spi_dat  => spi_dat,
            dat_ncfg => dat_ncfg,
            addr     => addr,
            data     => data,
            dat_lat  => dat_lat,
            cfg      => cfg,
            cfg_lat  => cfg_lat
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
        -- Initial state
        spi_clk <= '0';
        spi_dat <= '0';
        spi_cs  <= '1';
        
        -- ###########################################
        -- ### PART 1. DATA write
        -- ### test 1. Write with SPI CS toggling
        -- ############################################
        -- Trigger address clear
        wait for clk_period*num_cycles + clk_period/4;
        dat_ncfg  <= '0';
        wait for clk_period*num_cycles + clk_period/4;
        dat_ncfg  <= '1';
        -- SPI slave select
        wait for clk_period*num_cycles;
        spi_cs <= '0';
        -- Write test pattern
        dat_test <= "0000101010101010";
        wait for clk_period*num_cycles;
        for i in dat_test'high downto dat_test'low loop 
            spi_dat <= dat_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Cycle SPI CS
        wait for clk_period*num_cycles;
        spi_cs <= '1';
        wait for clk_period*num_cycles;
        spi_cs <= '0';
        wait for clk_period*num_cycles;
        -- Write second test pattern
        dat_test <= "0000110011001100";
        wait for clk_period*num_cycles;
        for i in dat_test'high downto dat_test'low loop 
            spi_dat <= dat_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Deselect
        wait for clk_period*num_cycles;
        spi_cs <= '1';
        wait for clk_period*num_cycles;
        -- ###########################################
        -- ### PART 1. DATA write
        -- ### test 2. Write without SPI CS toggling
        -- ############################################
        -- SPI slave select
        wait for clk_period*num_cycles;
        spi_cs <= '0';
        wait for clk_period*num_cycles;
        -- Write test pattern
        dat_test <= "0000101010101010";
        wait for clk_period*num_cycles;
        for i in dat_test'high downto dat_test'low loop 
            spi_dat <= dat_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Write second test pattern
        dat_test <= "0000110011001100";
        wait for clk_period*num_cycles;
        for i in dat_test'high downto dat_test'low loop 
            spi_dat <= dat_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Deselect
        wait for clk_period*num_cycles;
        spi_cs <= '1';
        -- ###########################################
        -- ### PART 1. DATA write
        -- ### test 3. Address reset
        -- ############################################
        -- Trigger address reset
        wait for clk_period*num_cycles + clk_period/4;
        dat_ncfg  <= '0';
        wait for clk_period*num_cycles + clk_period/4;
        dat_ncfg  <= '1';
        -- SPI slave select
        wait for clk_period*num_cycles;
        spi_cs <= '0';
        -- Write test pattern
        dat_test <= "0000101010101010";
        wait for clk_period*num_cycles;
        for i in dat_test'high downto dat_test'low loop 
            spi_dat <= dat_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Write second test pattern
        dat_test <= "0000110011001100";
        wait for clk_period*num_cycles;
        for i in dat_test'high downto dat_test'low loop 
            spi_dat <= dat_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Deselect
        wait for clk_period*num_cycles;
        spi_cs <= '1';

        wait for clk_period*num_cycles*10;

        -- ###########################################
        -- ### PART 2. CONFIGURATION write
        -- ############################################
        wait for clk_period*num_cycles + clk_period/4;
        dat_ncfg  <= '0';
        -- SPI slave select
        wait for clk_period*num_cycles;
        spi_cs <= '0';
        -- Write test pattern
        cfg_test <= "10101010101010101010101010101010";
        wait for clk_period*num_cycles;
        for i in cfg_test'high downto cfg_test'low loop 
            spi_dat <= cfg_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Deselect
        wait for clk_period*num_cycles;
        spi_cs <= '1';
        -- SPI slave select
        wait for clk_period*num_cycles;
        spi_cs <= '0';
        -- Write test pattern
        cfg_test <= "11001100110011001100110011001100";
        wait for clk_period*num_cycles;
        for i in cfg_test'high downto cfg_test'low loop 
            spi_dat <= cfg_test(i);
            wait for clk_period*num_cycles;
            spi_clk <= '1';
            wait for clk_period*num_cycles;
            spi_clk <= '0';
        end loop;
        -- Deselect
        wait for clk_period*num_cycles;
        spi_cs <= '1';

        -- Wait forever
        wait for 1 us;
        assert false report "simulation ended" severity failure;

    end process;
    
end tb;
