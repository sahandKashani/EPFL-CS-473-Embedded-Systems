library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package cmos_sensor_output_generator_constants is
    constant CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH : positive := 32;

    -- register offsets
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST       : std_logic_vector(2 downto 0) := "000"; -- RW
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST      : std_logic_vector(2 downto 0) := "001"; -- RW
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST : std_logic_vector(2 downto 0) := "010"; -- RW
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_OFST  : std_logic_vector(2 downto 0) := "011"; -- RW
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST   : std_logic_vector(2 downto 0) := "100"; -- RW
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_OFST  : std_logic_vector(2 downto 0) := "101"; -- RW
    constant CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST                  : std_logic_vector(2 downto 0) := "110"; -- WO
    constant CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST                   : std_logic_vector(2 downto 0) := "111"; -- RO

    -- CONFIG register minimum values
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_MIN       : positive := 1;
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_MIN      : positive := 1;
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_MIN : positive := 1;
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_MIN  : natural  := 0;
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_MIN   : positive := 1;
    constant CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_MIN  : natural  := 0;

    -- COMMAND register
    constant CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_WIDTH : positive                     := 1;
    constant CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_STOP  : std_logic_vector(0 downto 0) := "0";
    constant CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_START : std_logic_vector(0 downto 0) := "1";

    -- STATUS register
    constant CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_IDLE : std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0) := X"00000001";
    constant CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_BUSY : std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0) := X"00000000";

    function ceil_log2(num : positive) return natural;
    function bit_width(num : positive) return positive;
    function max(left : positive; right : positive) return positive;

end package cmos_sensor_output_generator_constants;

package body cmos_sensor_output_generator_constants is
    function ceil_log2(num : positive) return natural is
    begin
        return integer(ceil(log2(real(num))));
    end function ceil_log2;

    function bit_width(num : positive) return positive is
    begin
        return ceil_log2(num + 1);
    end function bit_width;

    function max(left : positive; right : positive) return positive is
    begin
        if left > right then
            return left;
        else
            return right;
        end if;
    end max;
end package body cmos_sensor_output_generator_constants;
