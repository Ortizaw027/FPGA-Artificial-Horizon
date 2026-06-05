-- IMU_Controller.vhd --
-- Two-phase FSM that drives the IMU over SPI. --
-- Phase 1 (once on startup): writes 7 config registers to set IMU range and bandwidth. --
-- Phase 2 (continuous loop): polls 12 bytes of accel and gyro data at ~1 kHz, --
-- then pulses o_Data_Valid when a complete 6-axis set is ready. --
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IMU_Controller is
    port(
        i_Clk        : in  std_logic;
        i_Rst_L      : in  std_logic;
        -- SPI Master interface --
        o_TX_Byte    : out std_logic_vector(7 downto 0);
        o_TX_DV      : out std_logic;
        i_TX_Ready   : in  std_logic;
        -- RX (MISO) --
        i_RX_DV      : in  std_logic;
        i_RX_Byte    : in  std_logic_vector(7 downto 0);
        -- Physical --
        o_IMU_CS_n   : out std_logic;
        o_LED_WHO    : out std_logic;
        -- Raw 16-bit sensor outputs --
        o_Accel_X    : out std_logic_vector(15 downto 0);
        o_Accel_Y    : out std_logic_vector(15 downto 0);
        o_Accel_Z    : out std_logic_vector(15 downto 0);
        o_Gyro_X     : out std_logic_vector(15 downto 0);
        o_Gyro_Y     : out std_logic_vector(15 downto 0);
        o_Gyro_Z     : out std_logic_vector(15 downto 0);
        o_Data_Valid : out std_logic);
end entity;

architecture RTL of IMU_Controller is

    type t_SM_IMU is (
        IDLE,
        PULL_CS, SEND_ADDR, SEND_DATA, WAIT_SPI, RELEASE_CS,
        INIT_DONE,
        POLLING_WAIT,
        READ_PULL_CS, READ_SEND_ADDR, READ_WAIT_TX,
        READ_DUMMY, READ_CAPTURE, READ_RELEASE_CS);

    signal r_SM_IMU : t_SM_IMU := IDLE;

    type t_Init_Array is array (0 to 6) of std_logic_vector(7 downto 0);

    -- CS setup and hold guard: 100 cycles at 74 MHz = ~1.35 us --
    constant c_CS_Wait      : integer := 100;

    -- IMU power-on boot delay: 14,800,000 cycles at 74 MHz = ~200 ms --
    constant c_BOOT_DELAY : integer := 14800000;

    -- Register addresses and config values written once at startup --
    constant c_Init_Addr : t_Init_Array :=
        (x"76", x"4E", x"4F", x"50", x"51", x"52", x"53");
    constant c_Init_Data : t_Init_Array :=
        (x"00", x"0F", x"66", x"66", x"0A", x"33", x"14");

    -- r_Cnt is dual-purpose: init register index (0-6) and RX byte index (0-11) --
    signal r_Cnt        : integer range 0 to 11       := 0;
    signal r_Wait_Cnt   : integer range 0 to 14800000 := 0;
    signal r_Next_State : t_SM_IMU;

    -- 74000 cycles at 74 MHz = ~1 ms between reads (~1 kHz sample rate) --
    signal r_Poll_Timer : integer range 0 to 74000 := 0;

    -- Internal capture registers; held until full 12-byte burst completes --
    signal r_Accel_X, r_Accel_Y, r_Accel_Z : std_logic_vector(15 downto 0) := (others => '0');
    signal r_Gyro_X,  r_Gyro_Y,  r_Gyro_Z  : std_logic_vector(15 downto 0) := (others => '0');

    -- Pulses high one clock when a complete 12-byte read finishes --
    signal r_DV_Reg : std_logic := '0';

begin
    -- Main FSM: boot delay, then init sequence, then continuous polling loop --
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Rst_L = '0' then
                r_SM_IMU     <= IDLE;
                r_Cnt        <= 0;
                r_Wait_Cnt   <= 0;
                r_Poll_Timer <= 0;
                o_IMU_CS_n   <= '1';
                o_TX_DV      <= '0';
                o_LED_WHO    <= '0';
            else
                o_TX_DV  <= '0';
                r_DV_Reg <= '0';

                case r_SM_IMU is

                    -- Hold CS deasserted for ~100 ms after power-on before touching IMU --
                    when IDLE =>
                        o_IMU_CS_n <= '1';
                        r_Cnt      <= 0;
                        if r_Wait_Cnt < c_BOOT_DELAY then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_IMU   <= PULL_CS;
                        end if;

                    -- Assert CS then wait for setup time before clocking --
                    when PULL_CS =>
                        o_IMU_CS_n <= '0';
                        if r_Wait_Cnt < c_CS_Wait then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_IMU   <= SEND_ADDR;
                        end if;

                    when SEND_ADDR =>
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= c_Init_Addr(r_Cnt);
                            o_TX_DV      <= '1';
                            r_Next_State <= SEND_DATA;
                            r_SM_IMU     <= WAIT_SPI;
                        end if;

                    when SEND_DATA =>
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= c_Init_Data(r_Cnt);
                            o_TX_DV      <= '1';
                            r_Next_State <= RELEASE_CS;
                            r_SM_IMU     <= WAIT_SPI;
                        end if;

                    -- Wait for SPI master to finish clocking the byte --
                    when WAIT_SPI =>
                        if i_TX_Ready = '1' and o_TX_DV = '0' then
                            r_SM_IMU <= r_Next_State;
                        end if;

                    -- Deassert CS with hold time; loop to next register or finish init --
                    when RELEASE_CS =>
                        o_IMU_CS_n <= '1';
                        if r_Wait_Cnt < c_CS_Wait then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            if r_Cnt < 6 then
                                r_Cnt    <= r_Cnt + 1;
                                r_SM_IMU <= PULL_CS;
                            else
                                r_SM_IMU <= INIT_DONE;
                            end if;
                        end if;

                    -- Init complete: light LED and enter polling loop --
                    when INIT_DONE =>
                        o_LED_WHO    <= '1';
                        r_Cnt        <= 0;
                        r_Poll_Timer <= 0;
                        r_SM_IMU     <= POLLING_WAIT;

                    -- ~1 ms gap between reads to match IMU output data rate --
                    when POLLING_WAIT =>
                        if r_Poll_Timer < 74000 then
                            r_Poll_Timer <= r_Poll_Timer + 1;
                        else
                            r_Poll_Timer <= 0;
                            r_SM_IMU     <= READ_PULL_CS;
                        end if;

                    when READ_PULL_CS =>
                        o_IMU_CS_n <= '0';
                        if r_Wait_Cnt < c_CS_Wait then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_IMU   <= READ_SEND_ADDR;
                        end if;

                    -- 0x9F = read bit (0x80) OR'd with start register (0x1F) --
                    when READ_SEND_ADDR =>
                        if i_TX_Ready = '1' then
                            o_TX_Byte <= x"9F";
                            o_TX_DV   <= '1';
                            r_SM_IMU  <= READ_WAIT_TX;
                        end if;

                    -- Wait for address byte to finish clocking before sending dummy --
                    when READ_WAIT_TX =>
                        if i_TX_Ready = '1' then
                            r_SM_IMU <= READ_DUMMY;
                        end if;

                    -- Clock out 0x00 to generate SCLK; IMU shifts out the next byte --
                    when READ_DUMMY =>
                        if i_TX_Ready = '1' then
                            o_TX_Byte <= x"00";
                            o_TX_DV   <= '1';
                            r_SM_IMU  <= READ_CAPTURE;
                        end if;

                    -- Assemble incoming bytes into 16-bit words MSB first; 12 bytes = 6 axes --
                    when READ_CAPTURE =>
                        if i_RX_DV = '1' then
                            case r_Cnt is
                                when 0  => r_Accel_X(15 downto 8) <= i_RX_Byte;
                                when 1  => r_Accel_X( 7 downto 0) <= i_RX_Byte;
                                when 2  => r_Accel_Y(15 downto 8) <= i_RX_Byte;
                                when 3  => r_Accel_Y( 7 downto 0) <= i_RX_Byte;
                                when 4  => r_Accel_Z(15 downto 8) <= i_RX_Byte;
                                when 5  => r_Accel_Z( 7 downto 0) <= i_RX_Byte;
                                when 6  => r_Gyro_X(15 downto 8)  <= i_RX_Byte;
                                when 7  => r_Gyro_X( 7 downto 0)  <= i_RX_Byte;
                                when 8  => r_Gyro_Y(15 downto 8)  <= i_RX_Byte;
                                when 9  => r_Gyro_Y( 7 downto 0)  <= i_RX_Byte;
                                when 10 => r_Gyro_Z(15 downto 8)  <= i_RX_Byte;
                                when 11 => r_Gyro_Z( 7 downto 0)  <= i_RX_Byte;
                                when others => null;
                            end case;

                            if r_Cnt = 11 then
                                r_Cnt    <= 0;
                                r_DV_Reg <= '1';
                                r_SM_IMU <= READ_RELEASE_CS;
                            else
                                r_Cnt    <= r_Cnt + 1;
                                r_SM_IMU <= READ_DUMMY;
                            end if;
                        end if;

                    when READ_RELEASE_CS =>
                        o_IMU_CS_n <= '1';
                        if r_Wait_Cnt < c_CS_Wait then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_IMU   <= POLLING_WAIT;
                        end if;

                    when others => r_SM_IMU <= IDLE;
                end case;
            end if;
        end if;
    end process;

    -- Output latch: only updates when a full 12-byte burst is complete. --
    -- Prevents Attitude_Engine from reading a partially updated sensor word. --
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if r_DV_Reg = '1' then
                o_Accel_X    <= r_Accel_X;
                o_Accel_Y    <= r_Accel_Y;
                o_Accel_Z    <= r_Accel_Z;
                o_Gyro_X     <= r_Gyro_X;
                o_Gyro_Y     <= r_Gyro_Y;
                o_Gyro_Z     <= r_Gyro_Z;
                o_Data_Valid <= '1';
            else
                o_Data_Valid <= '0';
            end if;
        end if;
    end process;

end architecture;