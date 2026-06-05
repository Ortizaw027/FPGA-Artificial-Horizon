-- Attitude_Engine.vhd --
-- Three-stage pipeline: Calibration -> IIR low-pass -> Complementary filter --
-- Outputs pitch and roll as Q8.8 signed degrees to the LCD_Controller. --
-- Board must be stationary and level during the 1024-sample calibration window. --
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Attitude_Engine is
    port(
        i_Clk         : in  std_logic;
        i_Rst_L       : in  std_logic;
        i_Sample_DV   : in  std_logic;
        i_Raw_Ax, i_Raw_Ay, i_Raw_Az : in std_logic_vector(15 downto 0);
        i_Raw_Gx, i_Raw_Gy, i_Raw_Gz : in std_logic_vector(15 downto 0);
        o_Clean_Ax, o_Clean_Ay, o_Clean_Az : out std_logic_vector(15 downto 0);
        o_Clean_Gx, o_Clean_Gy, o_Clean_Gz : out std_logic_vector(15 downto 0);
        o_Pitch_Angle : out signed(15 downto 0);  -- Q8.8 signed degrees --
        o_Roll_Angle  : out signed(15 downto 0);  -- Q8.8 signed degrees --
        o_Cal_Done    : out std_logic);
end entity Attitude_Engine;

architecture RTL of Attitude_Engine is

    constant c_CAL_SAMPLES      : integer := 1024;
    constant c_CAL_SAMPLES_LOG2 : integer := 10;  -- log2(1024); used for divide-by-shift --
    constant c_IIR_SHIFT        : integer := 3;   -- IIR alpha = 1/(2^3) = 1/8 --

    -- Gyro readings below this LSB threshold are zeroed before integration --
    -- 4 LSB ~ 0.03 deg/s at +/-250 dps (131 LSB per deg/s) --
    constant c_GYRO_DEADBAND : signed(15 downto 0) := to_signed(4, 16);

    type t_Cal_State is (CAL_ACCUM, CAL_DONE);
    signal r_Cal_State : t_Cal_State := CAL_ACCUM;
    signal r_Cal_Count : integer range 0 to c_CAL_SAMPLES := 0;
    signal r_Cal_Done  : std_logic := '0';

    -- 32-bit accumulators prevent overflow when summing 1024 x 16-bit samples --
    signal r_Acc_Ax : signed(31 downto 0) := (others => '0');
    signal r_Acc_Ay : signed(31 downto 0) := (others => '0');
    signal r_Acc_Az : signed(31 downto 0) := (others => '0');
    signal r_Acc_Gx : signed(31 downto 0) := (others => '0');
    signal r_Acc_Gy : signed(31 downto 0) := (others => '0');
    signal r_Acc_Gz : signed(31 downto 0) := (others => '0');

    -- Per-axis bias offsets frozen at end of calibration window --
    signal r_Bias_Ax : signed(15 downto 0) := (others => '0');
    signal r_Bias_Ay : signed(15 downto 0) := (others => '0');
    signal r_Bias_Az : signed(15 downto 0) := (others => '0');
    signal r_Bias_Gx : signed(15 downto 0) := (others => '0');
    signal r_Bias_Gy : signed(15 downto 0) := (others => '0');
    signal r_Bias_Gz : signed(15 downto 0) := (others => '0');

    -- Stage 1 output: bias-corrected samples --
    signal r_Ax_C : signed(15 downto 0) := (others => '0');
    signal r_Ay_C : signed(15 downto 0) := (others => '0');
    signal r_Az_C : signed(15 downto 0) := (others => '0');
    signal r_Gx_C : signed(15 downto 0) := (others => '0');
    signal r_Gy_C : signed(15 downto 0) := (others => '0');
    signal r_Gz_C : signed(15 downto 0) := (others => '0');

    -- Stage 2 output: IIR-filtered samples --
    signal r_Ax_F : signed(15 downto 0) := (others => '0');
    signal r_Ay_F : signed(15 downto 0) := (others => '0');
    signal r_Az_F : signed(15 downto 0) := (others => '0');
    signal r_Gx_F : signed(15 downto 0) := (others => '0');
    signal r_Gy_F : signed(15 downto 0) := (others => '0');
    signal r_Gz_F : signed(15 downto 0) := (others => '0');

    -- Pipeline delay: r_DV(0) clocks Stage 2, r_DV(1) clocks Stage 3 --
    signal r_DV : std_logic_vector(1 downto 0) := (others => '0');

    -- Angle accumulators in Q16.16 degrees --
    signal r_Pitch_Acc : signed(31 downto 0) := (others => '0');
    signal r_Roll_Acc  : signed(31 downto 0) := (others => '0');

    -- Final Q8.8 outputs, clamped to +/-180 degrees --
    signal r_Pitch_Out : signed(15 downto 0) := (others => '0');
    signal r_Roll_Out  : signed(15 downto 0) := (others => '0');

begin
    -- Stage 1: Calibration and bias subtraction --
    -- Accumulates 1024 stationary samples; bias = sum >> 10 (divide by 1024). --
    -- Az bias includes -16384 to remove 1g (16384 LSB = 1g at +/-2g range). --
    -- After calibration, subtracts frozen bias from every incoming sample. --

    p_Cal : process(i_Clk)
        variable v_Ax, v_Ay, v_Az : signed(15 downto 0);
        variable v_Gx, v_Gy, v_Gz : signed(15 downto 0);
    begin
        if rising_edge(i_Clk) then
            if i_Rst_L = '0' then
                r_Cal_State <= CAL_ACCUM;
                r_Cal_Count <= 0;
                r_Cal_Done  <= '0';
                r_Acc_Ax <= (others => '0'); r_Acc_Ay <= (others => '0');
                r_Acc_Az <= (others => '0'); r_Acc_Gx <= (others => '0');
                r_Acc_Gy <= (others => '0'); r_Acc_Gz <= (others => '0');
                r_Bias_Ax <= (others => '0'); r_Bias_Ay <= (others => '0');
                r_Bias_Az <= (others => '0'); r_Bias_Gx <= (others => '0');
                r_Bias_Gy <= (others => '0'); r_Bias_Gz <= (others => '0');
                r_Ax_C <= (others => '0'); r_Ay_C <= (others => '0');
                r_Az_C <= (others => '0'); r_Gx_C <= (others => '0');
                r_Gy_C <= (others => '0'); r_Gz_C <= (others => '0');
                r_DV   <= (others => '0');
            else
                -- Propagate sample pulse one clock per stage through the pipeline --
                r_DV(0) <= i_Sample_DV;
                r_DV(1) <= r_DV(0);

                if i_Sample_DV = '1' then
                    v_Ax := signed(i_Raw_Ax);
                    v_Ay := signed(i_Raw_Ay);
                    v_Az := signed(i_Raw_Az);
                    v_Gx := signed(i_Raw_Gx);
                    v_Gy := signed(i_Raw_Gy);
                    v_Gz := signed(i_Raw_Gz);

                    case r_Cal_State is

                        when CAL_ACCUM =>
                            r_Acc_Ax <= r_Acc_Ax + v_Ax;
                            r_Acc_Ay <= r_Acc_Ay + v_Ay;
                            r_Acc_Az <= r_Acc_Az + v_Az;
                            r_Acc_Gx <= r_Acc_Gx + v_Gx;
                            r_Acc_Gy <= r_Acc_Gy + v_Gy;
                            r_Acc_Gz <= r_Acc_Gz + v_Gz;

                            if r_Cal_Count = c_CAL_SAMPLES - 1 then
                                -- Freeze biases: average = sum >> log2(N) --
                                r_Bias_Ax <= resize(
                                    shift_right(r_Acc_Ax + v_Ax, c_CAL_SAMPLES_LOG2), 16);
                                r_Bias_Ay <= resize(
                                    shift_right(r_Acc_Ay + v_Ay, c_CAL_SAMPLES_LOG2), 16);
                                -- Subtract 16384 (1g) so flat-board Az reads 0 --
                                r_Bias_Az <= resize(
                                    shift_right(r_Acc_Az + v_Az, c_CAL_SAMPLES_LOG2)
                                    - 16384, 16);
                                r_Bias_Gx <= resize(
                                    shift_right(r_Acc_Gx + v_Gx, c_CAL_SAMPLES_LOG2), 16);
                                r_Bias_Gy <= resize(
                                    shift_right(r_Acc_Gy + v_Gy, c_CAL_SAMPLES_LOG2), 16);
                                r_Bias_Gz <= resize(
                                    shift_right(r_Acc_Gz + v_Gz, c_CAL_SAMPLES_LOG2), 16);
                                r_Cal_Done  <= '1';
                                r_Cal_State <= CAL_DONE;
                            else
                                r_Cal_Count <= r_Cal_Count + 1;
                            end if;

                        when CAL_DONE =>
                            -- Subtract static bias from every live sample --
                            r_Ax_C <= resize(v_Ax - r_Bias_Ax, 16);
                            r_Ay_C <= resize(v_Ay - r_Bias_Ay, 16);
                            r_Az_C <= resize(v_Az - r_Bias_Az, 16);
                            r_Gx_C <= resize(v_Gx - r_Bias_Gx, 16);
                            r_Gy_C <= resize(v_Gy - r_Bias_Gy, 16);
                            r_Gz_C <= resize(v_Gz - r_Bias_Gz, 16);

                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- Stage 2: First-order IIR low-pass filter --
    -- output = output + (input - output) >> 3 = (7/8)*output + (1/8)*input --
    -- Fires one cycle after Stage 1 via r_DV(0), gated until cal complete. --
    p_IIR : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Rst_L = '0' then
                r_Ax_F <= (others => '0'); r_Ay_F <= (others => '0');
                r_Az_F <= (others => '0'); r_Gx_F <= (others => '0');
                r_Gy_F <= (others => '0'); r_Gz_F <= (others => '0');
            elsif r_DV(0) = '1' and r_Cal_Done = '1' then
                r_Ax_F <= r_Ax_F + shift_right(r_Ax_C - r_Ax_F, c_IIR_SHIFT);
                r_Ay_F <= r_Ay_F + shift_right(r_Ay_C - r_Ay_F, c_IIR_SHIFT);
                r_Az_F <= r_Az_F + shift_right(r_Az_C - r_Az_F, c_IIR_SHIFT);
                r_Gx_F <= r_Gx_F + shift_right(r_Gx_C - r_Gx_F, c_IIR_SHIFT);
                r_Gy_F <= r_Gy_F + shift_right(r_Gy_C - r_Gy_F, c_IIR_SHIFT);
                r_Gz_F <= r_Gz_F + shift_right(r_Gz_C - r_Gz_F, c_IIR_SHIFT);
            end if;
        end if;
    end process;

    -- Stage 3: Complementary filter -> Q8.8 pitch and roll --
    -- Gyro:  integrates angular rate each sample (accurate short-term, drifts) --
    -- Accel: linear arcsin from gravity vector (stable long-term, noisy) --
    -- Blend: 61/64 gyro accumulator + gyro delta + 3/64 accel correction --
    --
    -- Gyro scaling:  LSB/2 -> Q16.16 deg  (131072 LSB/deg at 1 kHz -> /2) --
    -- Accel scaling: LSB*360 -> Q16.16 deg (linear approx: 16384 LSB = 90 deg) --
    -- Output:        Q16.16 >> 8 -> Q8.8, clamped to +/-180 deg (+/-46080) --
    p_Comp : process(i_Clk)
        variable v_Accel_Pitch : signed(31 downto 0);
        variable v_Accel_Roll  : signed(31 downto 0);
        variable v_Gyro_Pitch  : signed(31 downto 0);
        variable v_Gyro_Roll   : signed(31 downto 0);
        variable v_Gx_Dead     : signed(15 downto 0);
        variable v_Gy_Dead     : signed(15 downto 0);
        variable v_Out         : signed(31 downto 0);
    begin
        if rising_edge(i_Clk) then
            if i_Rst_L = '0' then
                r_Pitch_Acc <= (others => '0');
                r_Roll_Acc  <= (others => '0');
                r_Pitch_Out <= (others => '0');
                r_Roll_Out  <= (others => '0');
            elsif r_DV(1) = '1' and r_Cal_Done = '1' then

                -- Zero gyro values below deadband to suppress idle noise --
                if r_Gx_F > c_GYRO_DEADBAND or r_Gx_F < -c_GYRO_DEADBAND then
                    v_Gx_Dead := r_Gx_F;
                else
                    v_Gx_Dead := (others => '0');
                end if;

                if r_Gy_F > c_GYRO_DEADBAND or r_Gy_F < -c_GYRO_DEADBAND then
                    v_Gy_Dead := r_Gy_F;
                else
                    v_Gy_Dead := (others => '0');
                end if;

                -- Gyro delta this sample in Q16.16 degrees --
                v_Gyro_Pitch := resize(v_Gx_Dead, 32) / 2;
                v_Gyro_Roll  := resize(v_Gy_Dead, 32) / 2;

                -- Accel angle estimate in Q16.16 degrees (linear arcsin approx) --
                v_Accel_Pitch := resize(resize(r_Ax_F, 32) * to_signed(360, 16), 32);
                v_Accel_Roll  := resize(resize(r_Ay_F, 32) * to_signed(360, 16), 32);

                -- Decay accumulator by 61/64, add gyro delta, pull 3/64 toward accel --
                r_Pitch_Acc <= resize(shift_right(r_Pitch_Acc * to_signed(61, 16), 6), 32)
                               + v_Gyro_Pitch
                               + resize(shift_right(v_Accel_Pitch * to_signed(3, 16), 6), 32);

                r_Roll_Acc  <= resize(shift_right(r_Roll_Acc * to_signed(61, 16), 6), 32)
                               + v_Gyro_Roll
                               + resize(shift_right(v_Accel_Roll * to_signed(3, 16), 6), 32);

                -- Convert Q16.16 -> Q8.8 and clamp to +/-180 degrees --
                v_Out := shift_right(r_Pitch_Acc, 8);
                if v_Out > to_signed(46080, 32) then
                    r_Pitch_Out <= to_signed(46080, 16);
                elsif v_Out < to_signed(-46080, 32) then
                    r_Pitch_Out <= to_signed(-46080, 16);
                else
                    r_Pitch_Out <= v_Out(15 downto 0);
                end if;

                v_Out := shift_right(r_Roll_Acc, 8);
                if v_Out > to_signed(46080, 32) then
                    r_Roll_Out <= to_signed(46080, 16);
                elsif v_Out < to_signed(-46080, 32) then
                    r_Roll_Out <= to_signed(-46080, 16);
                else
                    r_Roll_Out <= v_Out(15 downto 0);
                end if;

            end if;
        end if;
    end process;

    -- Filtered samples available on outputs for debug probing --
    o_Clean_Ax <= std_logic_vector(r_Ax_F);
    o_Clean_Ay <= std_logic_vector(r_Ay_F);
    o_Clean_Az <= std_logic_vector(r_Az_F);
    o_Clean_Gx <= std_logic_vector(r_Gx_F);
    o_Clean_Gy <= std_logic_vector(r_Gy_F);
    o_Clean_Gz <= std_logic_vector(r_Gz_F);
    o_Pitch_Angle <= r_Pitch_Out;
    o_Roll_Angle  <= r_Roll_Out;
    o_Cal_Done    <= r_Cal_Done;

end architecture RTL;