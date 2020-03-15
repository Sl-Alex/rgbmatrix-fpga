-- Adafruit RGB LED Matrix Display Driver
-- Top Level Entity
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

use work.rgbmatrix.all; -- Constants & Configuration

entity top_level is
    port (
        -- Clock and reset inputs
        clk_in  : in std_logic;
        -- SPI inputs
        spi_cs  : in std_logic;
        spi_clk : in std_logic;
        spi_dat : in std_logic;
        dat_ncfg : in std_logic; -- Write 1->0->1 for data, 0->1->0 for configuration
        -- LED matrix outputs
        clk_out : out std_logic;
        r1      : out std_logic;
        r2      : out std_logic;
        b1      : out std_logic;
        b2      : out std_logic;
        g1      : out std_logic;
        g2      : out std_logic;
        a       : out std_logic;
        b       : out std_logic;
        c       : out std_logic;
        d       : out std_logic;
        lat     : out std_logic;
        oe      : out std_logic;
        -- Debug copy of LED matrix outputs
        clk_out_copy : out std_logic;
        r1_copy      : out std_logic;
        r2_copy      : out std_logic;
        b1_copy      : out std_logic;
        b2_copy      : out std_logic;
        g1_copy      : out std_logic;
        g2_copy      : out std_logic;
        a_copy       : out std_logic;
        b_copy       : out std_logic;
        c_copy       : out std_logic;
        d_copy       : out std_logic;
        lat_copy     : out std_logic;
        oe_copy      : out std_logic;
        -- Status LEDs
        led_frame_out : out std_logic;
        led_frame_in  : out std_logic;
        led_reset     : out std_logic
    );
end top_level;

architecture str of top_level is
    -- Reset signals
    signal rst : std_logic;
    
    -- Memory signals
    signal addr_wr : std_logic_vector(ADDR_WIDTH downto 0);
    signal addr_rd : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data_incoming : std_logic_vector(DATA_WIDTH/2-1 downto 0);
    signal data_outgoing : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal cfg_incoming : std_logic_vector(CONFIG_WIDTH-1 downto 0);
    
    -- Flags
    signal data_valid : std_logic;
    signal cfg_valid : std_logic;
    signal status_frame : std_logic;
begin

    led_reset <= not rst;
    
    -- LED panel controller
    U_LEDCTRL : entity work.ledctrl
        port map (
            rst => rst,
            clk_in => clk_in,
            -- Connection to LED panel
            clk_out => clk_out,
            rgb1(2) => r1,
            rgb1(1) => g1,
            rgb1(0) => b1,
            rgb2(2) => r2,
            rgb2(1) => g2,
            rgb2(0) => b2,
            led_addr(3) => d,
            led_addr(2) => c,
            led_addr(1) => b,
            led_addr(0) => a,
            lat => lat,
            oe  => oe,
            -- Connection to LED panel
            clk_out_copy => clk_out_copy,
            rgb1_copy(2) => r1_copy,
            rgb1_copy(1) => g1_copy,
            rgb1_copy(0) => b1_copy,
            rgb2_copy(2) => r2_copy,
            rgb2_copy(1) => g2_copy,
            rgb2_copy(0) => b2_copy,
            led_addr_copy(3) => d_copy,
            led_addr_copy(2) => c_copy,
            led_addr_copy(1) => b_copy,
            led_addr_copy(0) => a_copy,
            lat_copy => lat_copy,
            oe_copy  => oe_copy,
            -- Connection with framebuffer
            addr => addr_rd,
            data => data_outgoing,
            cfg => cfg_incoming, --"01110000000000000000000001000000",
            cfg_lat => cfg_valid,
            status_frame => led_frame_out
        );
    
    -- SPI input
    U_INPUT_REG : entity work.input_reg
        port map (
            -- System clock
            clk_in   => clk_in,
            -- SPI inputs
            spi_cs   => spi_cs,
            spi_clk  => spi_clk,
            spi_dat  => spi_dat,
            dat_ncfg => dat_ncfg,
            -- Memory outputs
            addr     => addr_wr,
            data     => data_incoming,
            dat_lat  => data_valid,
            cfg      => cfg_incoming,
            cfg_lat  => cfg_valid,
            status_frame => led_frame_in
        );
    
    -- Special memory for the framebuffer
    U_MEMORY : entity work.memory
        port map (
            -- Writing side
            clk_wr  => data_valid,
            addr_wr => addr_wr,
            input   => data_incoming,
            -- Reading side
            clk_rd  => clk_in,
            addr_rd => addr_rd,
            output  => data_outgoing
        );

    -- Instantiate the Unit Under Test (UUT)
    U_RESET_GEN : entity work.reset_generator
        generic map (
            RST_DELAY => RESET_DELAY,
            RST_LEN   => RESET_LEN
        )
        port map (
            clk_in   => clk_in,
            rst_out  => rst
        );

end str;
