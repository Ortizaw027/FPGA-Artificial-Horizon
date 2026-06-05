-- LCD_Controller.vhd --
-- Drives an ILI9341 240x320 LCD in portrait mode over SPI at ~18.5 MHz. --
-- Initialises the display then continuously redraws crosshair and --
-- attitude horizon at ~15 fps by computing a per-pixel threshold for all 76,800 pixels. --
--
-- Horizon math for each pixel (col, row): --
--   cx = col - 120,  cy = row - 160  (centre at screen midpoint) --
--   threshold = cx*(-sin(roll)) + cy*cos(roll) - pitch_offset --
--   threshold > 0  -> ground | threshold <= 0 -> sky --
--   |threshold| < HRZ_THICK*16384 -> white horizon band --
--
-- Sin/cos: 256-entry Q1.14 LUT; cos(x) = sin(x+64). --
-- Angles in Q8.8 signed degrees from Attitude_Engine. --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_Controller is
    port(
        i_Clk      : in  std_logic;
        i_Rst_L    : in  std_logic;
        i_Pitch    : in  signed(15 downto 0);  
        i_Roll     : in  signed(15 downto 0);  
        o_TX_Byte  : out std_logic_vector(7 downto 0);
        o_TX_DV    : out std_logic;
        i_TX_Ready : in  std_logic;
        o_LCD_CS_n : out std_logic;
        o_DC       : out std_logic;
        o_RST_n    : out std_logic);
end entity LCD_Controller;

architecture RTL of LCD_Controller is

    type t_SM_LCD is (
        IDLE,
        HW_RESET_LOW, HW_RESET_HIGH,
        SLEEP_OUT, SLEEP_WAIT,
        COLMOD_CMD, COLMOD_DATA,
        DISPLAY_ON,
        COL_CMD, COL_DATA,
        PAGE_CMD, PAGE_DATA,
        MEM_WRITE,
        PIXEL_CALC,
        PIXEL_SEND_HI,
        PIXEL_SEND_LO,
        WAIT_SPI);

    signal r_SM_LCD : t_SM_LCD := IDLE;

    type t_Param_Array is array (0 to 3) of std_logic_vector(7 downto 0);
    constant c_Col_Params  : t_Param_Array := (x"00", x"00", x"00", x"EF"); -- cols 0-239 --
    constant c_Page_Params : t_Param_Array := (x"00", x"00", x"01", x"3F"); -- rows 0-319 --

    -- RGB565 color constants --
    constant c_SKY_HI    : std_logic_vector(7 downto 0) := x"04";
    constant c_SKY_LO    : std_logic_vector(7 downto 0) := x"5F";
    constant c_GND_HI    : std_logic_vector(7 downto 0) := x"82";
    constant c_GND_LO    : std_logic_vector(7 downto 0) := x"00";
    constant c_HRZ_HI    : std_logic_vector(7 downto 0) := x"FF";
    constant c_HRZ_LO    : std_logic_vector(7 downto 0) := x"FF";
    constant c_HRZ_THICK : integer := 3;  -- horizon band half-thickness in pixels --

    -- Sin LUT: 256 Q1.14 entries covering full 360 degrees (1.0 = 16384) --
    -- cos(x) = sin(x+64) using the 256-step full-circle mapping --
    type t_Sin_LUT is array (0 to 255) of signed(15 downto 0);
    constant c_Sin_LUT : t_Sin_LUT := (
        to_signed(0,16),     to_signed(402,16),   to_signed(804,16),   to_signed(1205,16),
        to_signed(1606,16),  to_signed(2006,16),  to_signed(2404,16),  to_signed(2801,16),
        to_signed(3196,16),  to_signed(3589,16),  to_signed(3980,16),  to_signed(4369,16),
        to_signed(4756,16),  to_signed(5139,16),  to_signed(5520,16),  to_signed(5898,16),
        to_signed(6270,16),  to_signed(6639,16),  to_signed(7005,16),  to_signed(7366,16),
        to_signed(7723,16),  to_signed(8076,16),  to_signed(8423,16),  to_signed(8765,16),
        to_signed(9102,16),  to_signed(9434,16),  to_signed(9759,16),  to_signed(10079,16),
        to_signed(10393,16), to_signed(10701,16), to_signed(11003,16), to_signed(11297,16),
        to_signed(11585,16), to_signed(11866,16), to_signed(12140,16), to_signed(12406,16),
        to_signed(12665,16), to_signed(12916,16), to_signed(13160,16), to_signed(13395,16),
        to_signed(13623,16), to_signed(13842,16), to_signed(14053,16), to_signed(14256,16),
        to_signed(14449,16), to_signed(14635,16), to_signed(14811,16), to_signed(14978,16),
        to_signed(15137,16), to_signed(15286,16), to_signed(15426,16), to_signed(15557,16),
        to_signed(15679,16), to_signed(15791,16), to_signed(15893,16), to_signed(15986,16),
        to_signed(16069,16), to_signed(16143,16), to_signed(16207,16), to_signed(16261,16),
        to_signed(16305,16), to_signed(16340,16), to_signed(16364,16), to_signed(16379,16),
        to_signed(16384,16), to_signed(16379,16), to_signed(16364,16), to_signed(16340,16),
        to_signed(16305,16), to_signed(16261,16), to_signed(16207,16), to_signed(16143,16),
        to_signed(16069,16), to_signed(15986,16), to_signed(15893,16), to_signed(15791,16),
        to_signed(15679,16), to_signed(15557,16), to_signed(15426,16), to_signed(15286,16),
        to_signed(15137,16), to_signed(14978,16), to_signed(14811,16), to_signed(14635,16),
        to_signed(14449,16), to_signed(14256,16), to_signed(14053,16), to_signed(13842,16),
        to_signed(13623,16), to_signed(13395,16), to_signed(13160,16), to_signed(12916,16),
        to_signed(12665,16), to_signed(12406,16), to_signed(12140,16), to_signed(11866,16),
        to_signed(11585,16), to_signed(11297,16), to_signed(11003,16), to_signed(10701,16),
        to_signed(10393,16), to_signed(10079,16), to_signed(9759,16),  to_signed(9434,16),
        to_signed(9102,16),  to_signed(8765,16),  to_signed(8423,16),  to_signed(8076,16),
        to_signed(7723,16),  to_signed(7366,16),  to_signed(7005,16),  to_signed(6639,16),
        to_signed(6270,16),  to_signed(5898,16),  to_signed(5520,16),  to_signed(5139,16),
        to_signed(4756,16),  to_signed(4369,16),  to_signed(3980,16),  to_signed(3589,16),
        to_signed(3196,16),  to_signed(2801,16),  to_signed(2404,16),  to_signed(2006,16),
        to_signed(1606,16),  to_signed(1205,16),  to_signed(804,16),   to_signed(402,16),
        to_signed(0,16),     to_signed(-402,16),  to_signed(-804,16),  to_signed(-1205,16),
        to_signed(-1606,16), to_signed(-2006,16), to_signed(-2404,16), to_signed(-2801,16),
        to_signed(-3196,16), to_signed(-3589,16), to_signed(-3980,16), to_signed(-4369,16),
        to_signed(-4756,16), to_signed(-5139,16), to_signed(-5520,16), to_signed(-5898,16),
        to_signed(-6270,16), to_signed(-6639,16), to_signed(-7005,16), to_signed(-7366,16),
        to_signed(-7723,16), to_signed(-8076,16), to_signed(-8423,16), to_signed(-8765,16),
        to_signed(-9102,16), to_signed(-9434,16), to_signed(-9759,16), to_signed(-10079,16),
        to_signed(-10393,16),to_signed(-10701,16),to_signed(-11003,16),to_signed(-11297,16),
        to_signed(-11585,16),to_signed(-11866,16),to_signed(-12140,16),to_signed(-12406,16),
        to_signed(-12665,16),to_signed(-12916,16),to_signed(-13160,16),to_signed(-13395,16),
        to_signed(-13623,16),to_signed(-13842,16),to_signed(-14053,16),to_signed(-14256,16),
        to_signed(-14449,16),to_signed(-14635,16),to_signed(-14811,16),to_signed(-14978,16),
        to_signed(-15137,16),to_signed(-15286,16),to_signed(-15426,16),to_signed(-15557,16),
        to_signed(-15679,16),to_signed(-15791,16),to_signed(-15893,16),to_signed(-15986,16),
        to_signed(-16069,16),to_signed(-16143,16),to_signed(-16207,16),to_signed(-16261,16),
        to_signed(-16305,16),to_signed(-16340,16),to_signed(-16364,16),to_signed(-16379,16),
        to_signed(-16384,16),to_signed(-16379,16),to_signed(-16364,16),to_signed(-16340,16),
        to_signed(-16305,16),to_signed(-16261,16),to_signed(-16207,16),to_signed(-16143,16),
        to_signed(-16069,16),to_signed(-15986,16),to_signed(-15893,16),to_signed(-15791,16),
        to_signed(-15679,16),to_signed(-15557,16),to_signed(-15426,16),to_signed(-15286,16),
        to_signed(-15137,16),to_signed(-14978,16),to_signed(-14811,16),to_signed(-14635,16),
        to_signed(-14449,16),to_signed(-14256,16),to_signed(-14053,16),to_signed(-13842,16),
        to_signed(-13623,16),to_signed(-13395,16),to_signed(-13160,16),to_signed(-12916,16),
        to_signed(-12665,16),to_signed(-12406,16),to_signed(-12140,16),to_signed(-11866,16),
        to_signed(-11585,16),to_signed(-11297,16),to_signed(-11003,16),to_signed(-10701,16),
        to_signed(-10393,16),to_signed(-10079,16),to_signed(-9759,16), to_signed(-9434,16),
        to_signed(-9102,16), to_signed(-8765,16), to_signed(-8423,16), to_signed(-8076,16),
        to_signed(-7723,16), to_signed(-7366,16), to_signed(-7005,16), to_signed(-6639,16),
        to_signed(-6270,16), to_signed(-5898,16), to_signed(-5520,16), to_signed(-5139,16),
        to_signed(-4756,16), to_signed(-4369,16), to_signed(-3980,16), to_signed(-3589,16),
        to_signed(-3196,16), to_signed(-2801,16), to_signed(-2404,16), to_signed(-2006,16),
        to_signed(-1606,16), to_signed(-1205,16), to_signed(-804,16),  to_signed(-402,16));

    signal r_Cnt        : integer range 0 to 4       := 0;
    signal r_Wait_Cnt   : integer range 0 to 3240000 := 0;
    signal r_Pixel_Cnt  : integer range 0 to 76799   := 0;
    signal r_Next_State : t_SM_LCD;
    signal r_Col        : integer range 0 to 239     := 0;
    signal r_Row        : integer range 0 to 319     := 0;

    -- Roll LUT index and latched sin/cos; computed once per frame in COL_CMD --
    signal r_Roll_Idx  : unsigned(7 downto 0) := (others => '0');
    signal r_Sin_Roll  : signed(15 downto 0)  := (others => '0');
    signal r_Cos_Roll  : signed(15 downto 0)  := (others => '0');

    signal r_CX : signed(15 downto 0) := (others => '0');
    signal r_CY : signed(15 downto 0) := (others => '0');

    -- Pitch offset in Q1.14 pixel-space; computed once per frame --
    signal r_Pitch_Px  : signed(15 downto 0) := (others => '0');

    -- Horizon threshold in Q1.14 scaled space; positive = ground, negative = sky --
    signal r_Threshold : signed(31 downto 0) := (others => '0');

    signal r_Pix_Hi : std_logic_vector(7 downto 0) := (others => '0');
    signal r_Pix_Lo : std_logic_vector(7 downto 0) := (others => '0');

    -- Pitch and roll latched at frame start to prevent mid-frame tearing --
    signal r_Pitch_Latch : signed(15 downto 0) := (others => '0');
    signal r_Roll_Latch  : signed(15 downto 0) := (others => '0');

begin

    process(i_Clk)
        variable v_cos_idx : integer range 0 to 255;
    begin
        if rising_edge(i_Clk) then
            if i_Rst_L = '0' then
                r_SM_LCD    <= IDLE;
                r_Cnt       <= 0;
                r_Wait_Cnt  <= 0;
                r_Pixel_Cnt <= 0;
                r_Col       <= 0;
                r_Row       <= 0;
                o_LCD_CS_n  <= '1';
                o_DC        <= '0';
                o_RST_n     <= '1';
                o_TX_DV     <= '0';
            else
                o_TX_DV <= '0';

                case r_SM_LCD is

                    -- Initial power-on delay before touching the display --
                    when IDLE =>
                        o_LCD_CS_n <= '1';
                        o_RST_n    <= '1';
                        o_DC       <= '0';
                        if r_Wait_Cnt < 1350000 then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_LCD   <= HW_RESET_LOW;
                        end if;

                    -- Assert RST low for ~3.6 ms --
                    when HW_RESET_LOW =>
                        o_RST_n <= '0';
                        if r_Wait_Cnt < 270000 then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_LCD   <= HW_RESET_HIGH;
                        end if;

                    -- Hold RST high for ~44 ms before sending commands --
                    when HW_RESET_HIGH =>
                        o_RST_n <= '1';
                        if r_Wait_Cnt < 3240000 then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_LCD   <= SLEEP_OUT;
                        end if;

                    when SLEEP_OUT =>
                        o_LCD_CS_n <= '0';
                        o_DC       <= '0';
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= x"11";  -- SLPOUT command --
                            o_TX_DV      <= '1';
                            r_Next_State <= SLEEP_WAIT;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    -- ILI9341 requires 120 ms after SLPOUT before next command --
                    when SLEEP_WAIT =>
                        o_LCD_CS_n <= '1';
                        if r_Wait_Cnt < 3240000 then
                            r_Wait_Cnt <= r_Wait_Cnt + 1;
                        else
                            r_Wait_Cnt <= 0;
                            r_SM_LCD   <= COLMOD_CMD;
                        end if;

                    when COLMOD_CMD =>
                        o_LCD_CS_n <= '0';
                        o_DC       <= '0';
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= x"3A";  -- COLMOD: set pixel format --
                            o_TX_DV      <= '1';
                            r_Next_State <= COLMOD_DATA;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    when COLMOD_DATA =>
                        o_DC <= '1';
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= x"55";  -- 0x55 = 16-bit RGB565 --
                            o_TX_DV      <= '1';
                            r_Next_State <= DISPLAY_ON;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    when DISPLAY_ON =>
                        o_LCD_CS_n <= '0';
                        o_DC       <= '0';
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= x"29";  -- DISPON --
                            o_TX_DV      <= '1';
                            r_Next_State <= COL_CMD;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    -- Frame start: latch pitch/roll and precompute sin/cos and --
                    -- pitch offset once so all 76,800 pixels use the same values. --
                    -- Prevents attitude from changing mid-frame (tearing). --
                    when COL_CMD =>
                        o_LCD_CS_n    <= '0';
                        o_DC          <= '0';
                        r_Pitch_Latch <= i_Pitch;
                        r_Roll_Latch  <= i_Roll;
                        -- Map Q8.8 roll degrees to 0-255 LUT index: deg * 256/360 ~ deg * 91/128 --
                        r_Roll_Idx <= unsigned(
                            resize((resize(i_Roll(15 downto 8), 16) * 91) / 128, 8));
                        r_Sin_Roll <= c_Sin_LUT(to_integer(
                            unsigned(resize((resize(i_Roll(15 downto 8), 16) * 91) / 128, 8))));
                        -- cos(roll) = sin(roll + 90 deg) = sin(index + 64) in 256-step space --
                        r_Cos_Roll <= c_Sin_LUT((to_integer(
                            unsigned(resize((resize(i_Roll(15 downto 8), 16) * 91) / 128, 8))) + 64) mod 256);
                        -- Pitch offset: +ve pitch moves horizon down (more sky above nose) --
                        -- Q8.8 degrees -> Q1.14 pixel-space: pitch_deg * (320px/180deg) * 16384 --
                        r_Pitch_Px <= resize((i_Pitch * 16) / (9 * 256), 16);
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= x"2A";  -- CASET: column address set --
                            o_TX_DV      <= '1';
                            r_Cnt        <= 0;
                            r_Next_State <= COL_DATA;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    when COL_DATA =>
                        o_DC <= '1';
                        if i_TX_Ready = '1' then
                            o_TX_Byte <= c_Col_Params(r_Cnt);
                            o_TX_DV   <= '1';
                            if r_Cnt = 3 then
                                r_Cnt        <= 0;
                                r_Next_State <= PAGE_CMD;
                            else
                                r_Cnt        <= r_Cnt + 1;
                                r_Next_State <= COL_DATA;
                            end if;
                            r_SM_LCD <= WAIT_SPI;
                        end if;

                    when PAGE_CMD =>
                        o_LCD_CS_n <= '0';
                        o_DC       <= '0';
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= x"2B";  -- PASET: page (row) address set --
                            o_TX_DV      <= '1';
                            r_Next_State <= PAGE_DATA;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    when PAGE_DATA =>
                        o_DC <= '1';
                        if i_TX_Ready = '1' then
                            o_TX_Byte <= c_Page_Params(r_Cnt);
                            o_TX_DV   <= '1';
                            if r_Cnt = 3 then
                                r_Cnt        <= 0;
                                r_Next_State <= MEM_WRITE;
                            else
                                r_Cnt        <= r_Cnt + 1;
                                r_Next_State <= PAGE_DATA;
                            end if;
                            r_SM_LCD <= WAIT_SPI;
                        end if;

                    when MEM_WRITE =>
                        o_LCD_CS_n <= '0';
                        o_DC       <= '0';
                        if i_TX_Ready = '1' then
                            o_TX_Byte    <= x"2C";  -- RAMWR: begin pixel data stream --
                            o_TX_DV      <= '1';
                            r_Pixel_Cnt  <= 0;
                            r_Col        <= 0;
                            r_Row        <= 0;
                            r_Next_State <= PIXEL_CALC;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    -- Compute horizon threshold for pixel (r_Col, r_Row) --
                    -- sin is negated to rotate horizon opposite to board tilt --
                    -- Edge columns 0-1 and 238-239 forced black to hide roll wrap artifact --
                    when PIXEL_CALC =>
                        if r_Col < 2 or r_Col > 237 then
                            r_Threshold <= (others => '1');
                        else
                            r_Threshold <=
                                (to_signed(r_Col, 16) - 120) * (-r_Sin_Roll)
                              + (to_signed(r_Row, 16) - 160) * r_Cos_Roll
                              - resize(r_Pitch_Px * to_signed(16384, 16), 32);
                        end if;
                        r_SM_LCD <= PIXEL_SEND_HI;

                    -- Select RGB565 color based on threshold; aircraft symbol drawn on top --
                    -- Aircraft symbol: fixed screen coordinates, always black --
                    --   Centre dot: 8x8px box at (116-124, 156-164) --
                    --   Left wing:  2px tall bar from col 70 to 112 --
                    --   Right wing: 2px tall bar from col 128 to 170 --
                    when PIXEL_SEND_HI =>
                        o_DC <= '1';
                        if i_TX_Ready = '1' then
                            if (r_Col >= 116 and r_Col <= 124 and
                                r_Row >= 156 and r_Row <= 164) or
                               (r_Col >= 70  and r_Col <= 112 and
                                r_Row >= 159 and r_Row <= 161) or
                               (r_Col >= 128 and r_Col <= 170 and
                                r_Row >= 159 and r_Row <= 161) then
                                r_Pix_Hi <= x"00";
                                r_Pix_Lo <= x"00";
                            elsif r_Col < 2 or r_Col > 237 then
                                r_Pix_Hi <= x"00";
                                r_Pix_Lo <= x"00";
                            elsif r_Threshold < to_signed( 16384 * c_HRZ_THICK, 32) and
                                  r_Threshold > to_signed(-16384 * c_HRZ_THICK, 32) then
                                r_Pix_Hi <= c_HRZ_HI;
                                r_Pix_Lo <= c_HRZ_LO;
                            elsif r_Threshold > 0 then
                                r_Pix_Hi <= c_SKY_HI;
                                r_Pix_Lo <= c_SKY_LO;
                            else
                                r_Pix_Hi <= c_GND_HI;
                                r_Pix_Lo <= c_GND_LO;
                            end if;
                            o_TX_Byte    <= r_Pix_Hi;
                            o_TX_DV      <= '1';
                            r_Next_State <= PIXEL_SEND_LO;
                            r_SM_LCD     <= WAIT_SPI;
                        end if;

                    when PIXEL_SEND_LO =>
                        o_DC <= '1';
                        if i_TX_Ready = '1' then
                            o_TX_Byte <= r_Pix_Lo;
                            o_TX_DV   <= '1';
                            -- Advance col then row; loop back to COL_CMD for next frame --
                            if r_Col = 239 then
                                r_Col <= 0;
                                if r_Row = 319 then
                                    r_Row        <= 0;
                                    r_Next_State <= COL_CMD;
                                else
                                    r_Row        <= r_Row + 1;
                                    r_Next_State <= PIXEL_CALC;
                                end if;
                            else
                                r_Col        <= r_Col + 1;
                                r_Next_State <= PIXEL_CALC;
                            end if;
                            r_SM_LCD <= WAIT_SPI;
                        end if;

                    -- Wait for SPI master to accept the byte before advancing --
                    when WAIT_SPI =>
                        if i_TX_Ready = '1' and o_TX_DV = '0' then
                            r_SM_LCD <= r_Next_State;
                        end if;

                    when others =>
                        r_SM_LCD <= IDLE;

                end case;
            end if;
        end if;
    end process;

end architecture RTL;