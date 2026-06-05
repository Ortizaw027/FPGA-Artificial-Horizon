library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top is
    port(
        i_Clk       : in  std_logic;
        i_Rst_L     : in  std_logic;
        -- IMU SPI --
        i_IMU_MISO  : in  std_logic;
        o_IMU_SCLK  : out std_logic;
        o_IMU_MOSI  : out std_logic;
        o_IMU_CS_n  : out std_logic;
        o_LED_WHO   : out std_logic;
        -- LCD SPI --
        i_LCD_MISO  : in  std_logic;
        o_LCD_SCLK  : out std_logic;
        o_LCD_MOSI  : out std_logic;
        o_LCD_CS_n  : out std_logic;
        o_LCD_DC    : out std_logic;
        o_LCD_RST_n : out std_logic);
end entity;

architecture RTL of Top is

    signal w_Sys_Rst  : std_logic;
    signal w_PLL_Lock : std_logic;
    signal w_Clk_74   : std_logic;

    -- IMU SPI --
    signal w_IMU_TX_Byte  : std_logic_vector(7 downto 0);
    signal w_IMU_TX_DV    : std_logic;
    signal w_IMU_TX_Ready : std_logic;
    signal w_IMU_RX_DV    : std_logic;
    signal w_IMU_RX_Byte  : std_logic_vector(7 downto 0);

    -- LCD SPI --
    signal w_LCD_TX_Byte  : std_logic_vector(7 downto 0);
    signal w_LCD_TX_DV    : std_logic;
    signal w_LCD_TX_Ready : std_logic;

    -- Raw 16-bit accel and gyro words from IMU_Controller --
    signal w_Ax, w_Ay, w_Az : std_logic_vector(15 downto 0);
    signal w_Gx, w_Gy, w_Gz : std_logic_vector(15 downto 0);
    signal w_IMU_Data_Ready  : std_logic;

    -- Q8.8 signed degrees from Attitude_Engine to LCD_Controller --
    signal w_Pitch : signed(15 downto 0);
    signal w_Roll  : signed(15 downto 0);

    component Gowin_rPLL
        port (
            clkout : out std_logic;
            lock   : out std_logic;
            clkin  : in  std_logic);
    end component;

begin

    -- System stays in reset until button released AND PLL locked --
    w_Sys_Rst <= i_Rst_L and w_PLL_Lock;

    u_PLL : Gowin_rPLL
        port map (
            clkout => w_Clk_74,
            lock   => w_PLL_Lock,
            clkin  => i_Clk);

    -- IMU SPI Master --
    u_IMU_MASTER : entity work.SPI_Master
        generic map (
            SPI_MODE          => 0,
            CLKS_PER_HALF_BIT => 8)
        port map (
            i_Rst_L    => w_Sys_Rst,
            i_Clk      => w_Clk_74,
            i_TX_Byte  => w_IMU_TX_Byte,
            i_TX_DV    => w_IMU_TX_DV,
            o_TX_Ready => w_IMU_TX_Ready,
            o_RX_DV    => w_IMU_RX_DV,
            o_RX_Byte  => w_IMU_RX_Byte,
            o_SPI_Clk  => o_IMU_SCLK,
            i_SPI_MISO => i_IMU_MISO,
            o_SPI_MOSI => o_IMU_MOSI);

    -- LCD SPI Master --
    u_LCD_MASTER : entity work.SPI_Master
        generic map (
            SPI_MODE          => 0,
            CLKS_PER_HALF_BIT => 2)
        port map (
            i_Rst_L    => w_Sys_Rst,
            i_Clk      => w_Clk_74,
            i_TX_Byte  => w_LCD_TX_Byte,
            i_TX_DV    => w_LCD_TX_DV,
            o_TX_Ready => w_LCD_TX_Ready,
            o_RX_DV    => open,
            o_RX_Byte  => open,
            o_SPI_Clk  => o_LCD_SCLK,
            i_SPI_MISO => i_LCD_MISO,
            o_SPI_MOSI => o_LCD_MOSI);

    -- Initialises IMU over SPI then polls accel/gyro registers at ~1 kHz --
    u_IMU : entity work.IMU_Controller
        port map (
            i_Rst_L      => w_Sys_Rst,
            i_Clk        => w_Clk_74,
            o_TX_Byte    => w_IMU_TX_Byte,
            o_TX_DV      => w_IMU_TX_DV,
            i_TX_Ready   => w_IMU_TX_Ready,
            i_RX_Byte    => w_IMU_RX_Byte,
            i_RX_DV      => w_IMU_RX_DV,
            o_IMU_CS_n   => o_IMU_CS_n,
            o_LED_WHO    => o_LED_WHO,
            o_Accel_X    => w_Ax,
            o_Accel_Y    => w_Ay,
            o_Accel_Z    => w_Az,
            o_Gyro_X     => w_Gx,
            o_Gyro_Y     => w_Gy,
            o_Gyro_Z     => w_Gz,
            o_Data_Valid => w_IMU_Data_Ready);

    -- Calibrates, filters, and fuses accel/gyro into Q8.8 pitch and roll --
    u_Attitude : entity work.Attitude_Engine
        port map (
            i_Clk         => w_Clk_74,
            i_Rst_L       => w_Sys_Rst,
            i_Sample_DV   => w_IMU_Data_Ready,
            i_Raw_Ax      => w_Ax,
            i_Raw_Ay      => w_Ay,
            i_Raw_Az      => w_Az,
            i_Raw_Gx      => w_Gx,
            i_Raw_Gy      => w_Gy,
            i_Raw_Gz      => w_Gz,
            o_Pitch_Angle => w_Pitch,
            o_Roll_Angle  => w_Roll);

    -- Renders horizon for every pixel and streams RGB565 to LCD over SPI --
    u_LCD : entity work.LCD_Controller
        port map (
            i_Rst_L    => w_Sys_Rst,
            i_Clk      => w_Clk_74,
            i_Pitch    => w_Pitch,
            i_Roll     => w_Roll,
            o_TX_Byte  => w_LCD_TX_Byte,
            o_TX_DV    => w_LCD_TX_DV,
            i_TX_Ready => w_LCD_TX_Ready,
            o_LCD_CS_n => o_LCD_CS_n,
            o_DC       => o_LCD_DC,
            o_RST_n    => o_LCD_RST_n);

end architecture RTL;