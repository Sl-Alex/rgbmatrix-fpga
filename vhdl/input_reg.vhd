-- RGB LED Matrix Display Driver for FM6126A-based panels
-- Input shift register with address, data and latch output.
-- Supports data and configuration modes.
-- 
-- Copyright (c) 2020 Oleksii Slabchenko <https://sl-alex.net>
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
use ieee.numeric_std.all;

use work.rgbmatrix.all;

entity input_reg is
    port (
        -- System clock
        clk_in   : in  std_logic;
        -- SPI inputs
        spi_cs   : in  std_logic;
        spi_clk  : in  std_logic;
        spi_dat  : in std_logic;
        dat_ncfg : in std_logic;
        -- Memory outputs
        addr     : out std_logic_vector(ADDR_WIDTH downto 0);
        data     : out std_logic_vector(DATA_WIDTH/2-1 downto 0);
        dat_lat  : out std_logic;
        cfg      : out std_logic_vector(CONFIG_WIDTH-1 downto 0);
        cfg_lat  : out std_logic;
        -- status_frame
        status_frame : out std_logic
        );
end input_reg;

architecture bhv of input_reg is
    -- Essential state machine signals
    type MODE_TYPE is (MODE_DAT, MODE_CFG);
    signal s_mode, next_mode : MODE_TYPE := MODE_DAT;
    
    -- State machine signals
    signal s_bit_count, next_bit_count : unsigned(6 downto 0) := (others => '0');
    signal s_data, next_data: std_logic_vector(DATA_WIDTH/2-1 downto 0);
    signal s_cfg, next_cfg: std_logic_vector(CONFIG_WIDTH-1 downto 0);
    signal s_dat_lat, next_dat_lat : std_logic;
    signal s_cfg_lat, next_cfg_lat : std_logic;
    signal s_addr, next_addr : std_logic_vector(ADDR_WIDTH downto 0);
    signal s_dat_ncfg, s_spi_clk, s_spi_dat, s_spi_cs: std_logic;
    signal prev_dat_ncfg, prev_spi_clk: std_logic;
    signal s_frame, next_frame: std_logic;
begin
    
    -- Breakout internal signals to the output port
    addr    <= s_addr;
    data    <= s_data;
    dat_lat <= s_dat_lat;
    cfg     <= s_cfg;
    cfg_lat <= s_cfg_lat;
    status_frame <= s_frame;

    -- Update registers
    process(clk_in, dat_ncfg, s_dat_ncfg, s_spi_clk, spi_clk)
    begin
        if(rising_edge(clk_in)) then
            s_dat_ncfg <= dat_ncfg;
            prev_dat_ncfg <= s_dat_ncfg;
            s_spi_clk <= spi_clk;
            prev_spi_clk <= s_spi_clk;
            s_spi_dat <= spi_dat;
            s_spi_cs <= spi_cs;
            s_data <= next_data;
            s_cfg <= next_cfg;
            s_dat_lat <= next_dat_lat;
            s_cfg_lat <= next_cfg_lat;
            s_addr <= next_addr;
            s_mode <= next_mode;
            s_bit_count <= next_bit_count;
            s_frame <= next_frame;
        end if;
    end process;
    
    -- Next-state logic
    process(s_data, s_addr, s_cfg, s_bit_count, s_mode, s_dat_lat, s_cfg_lat, prev_spi_clk, s_spi_clk, s_spi_dat, s_dat_ncfg, prev_dat_ncfg, s_spi_cs, s_frame) is
    begin
        
        -- Default next-state assignments
        next_data <= s_data;
        next_cfg  <= s_cfg;
        next_bit_count <= s_bit_count;
        -- Stay in the current mode by default
        next_mode <= s_mode;
        next_addr <= s_addr;

        next_frame <= s_frame;

        -- Next latch state is low by default
        next_dat_lat <= s_dat_lat;
        next_cfg_lat <= s_cfg_lat;

        -- Modes
        case s_mode is
            when MODE_DAT =>
                -- Rising edge of spi_clk
                if prev_spi_clk = '0' and s_spi_clk = '1' then
                    next_dat_lat <= '0'; -- latch the data
                    next_data(0) <= s_spi_dat;
                    next_data(DATA_WIDTH/2-1 downto 1) <= s_data(DATA_WIDTH/2-2 downto 0);
                    next_bit_count <= s_bit_count + 1;
                end if;
                if prev_spi_clk = '1' and s_spi_clk = '1' then
                    if s_bit_count = INPUT_WIDTH then
                        next_dat_lat <= '1';
                        next_bit_count <= (others => '0');
                    end if;
                end if;
                -- Falling edge of spi_clk
                if prev_spi_clk = '1' and s_spi_clk = '0' then
                    if s_dat_lat = '1' then
                        next_addr <= std_logic_vector(unsigned(s_addr) + 1);
                        if unsigned(s_addr) = 2**ADDR_WIDTH - 1 then
                            next_frame <= not s_frame;
                        end if;
                        next_data <= (others => '0');
                    end if;
                    next_dat_lat <= '0'; -- latch the data
                end if;
            when MODE_CFG =>
                -- Rising edge of spi_clk
                if prev_spi_clk = '0' and s_spi_clk = '1' then
                    next_cfg_lat <= '0'; -- latch the data
                    next_cfg(0) <= s_spi_dat;
                    next_cfg(CONFIG_WIDTH-1 downto 1) <= s_cfg(CONFIG_WIDTH-2 downto 0);
                    next_bit_count <= s_bit_count + 1;
                end if;
                if prev_spi_clk = '1' and s_spi_clk = '1' then
                    if s_bit_count = CONFIG_WIDTH then
                        next_cfg_lat <= '1';
                        next_bit_count <= (others => '0');
                    end if;
                end if;
                -- Falling edge of spi_clk
                if prev_spi_clk = '1' and s_spi_clk = '0' then
                    if s_cfg_lat = '1' then
                        next_cfg <= (others => '0');
                    end if;
                    next_cfg_lat <= '0'; -- latch the data
                end if;
        end case;
        
        -- Common part for all modes, overrides all above
        if s_dat_ncfg /= prev_dat_ncfg then
            -- Reset all counters
            next_bit_count <= (others => '0');
            next_addr <= (others => '0');
            -- Reset all registers
            next_data <= (others => '0');
            next_cfg <= (others => '0');
            -- Clear all latch outputs
            next_dat_lat <= '0';
            next_cfg_lat <= '0';
            if (s_dat_ncfg = '1') then
                next_mode <= MODE_DAT;
            else
                next_mode <= MODE_CFG;
            end if;
        end if;
        
        if s_spi_cs = '1' then
            next_bit_count <= (others => '0');
            next_dat_lat <= '0';
            next_cfg_lat <= '0';
            next_data <= (others => '0');
            next_cfg <= (others => '0');
        end if;

    end process;
    
end bhv;
