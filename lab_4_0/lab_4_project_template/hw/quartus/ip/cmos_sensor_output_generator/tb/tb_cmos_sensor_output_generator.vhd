library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cmos_sensor_output_generator_constants.all;

entity tb_cmos_sensor_output_generator is
end tb_cmos_sensor_output_generator;

architecture test of tb_cmos_sensor_output_generator is
    -- 10 MHz -> 100 ns period. Duty cycle = 1/2.
    constant CLK_PERIOD      : time := 100 ns;
    constant CLK_HIGH_PERIOD : time := 50 ns;
    constant CLK_LOW_PERIOD  : time := 50 ns;

    signal clk   : std_logic;
    signal reset : std_logic;

    signal sim_finished : boolean := false;

    -- cmos_sensor_output_generator --------------------------------------------
    constant PIX_DEPTH         : positive := 8;
    constant MAX_WIDTH         : positive := 1920;
    constant MAX_HEIGHT        : positive := 1080;
    constant FRAME_WIDTH       : positive := 5;
    constant FRAME_HEIGHT      : positive := 4;
    constant FRAME_FRAME_BLANK : positive := 1;
    constant FRAME_LINE_BLANK  : natural  := 1;
    constant LINE_LINE_BLANK   : positive := 1;
    constant LINE_FRAME_BLANK  : natural  := 1;

    signal addr        : std_logic_vector(2 downto 0);
    signal read        : std_logic;
    signal write       : std_logic;
    signal rddata      : std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);
    signal wrdata      : std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);
    signal frame_valid : std_logic;
    signal line_valid  : std_logic;
    signal data        : std_logic_vector(PIX_DEPTH - 1 downto 0);

begin
    clk_generation : process
    begin
        if not sim_finished then
            clk <= '1';
            wait for CLK_HIGH_PERIOD;
            clk <= '0';
            wait for CLK_LOW_PERIOD;
        else
            wait;
        end if;
    end process clk_generation;

    cmos_sensor_output_generator_inst : entity work.cmos_sensor_output_generator
        generic map(PIX_DEPTH  => PIX_DEPTH,
                    MAX_WIDTH  => MAX_WIDTH,
                    MAX_HEIGHT => MAX_HEIGHT)
        port map(clk         => clk,
                 reset       => reset,
                 addr        => addr,
                 read        => read,
                 write       => write,
                 rddata      => rddata,
                 wrdata      => wrdata,
                 frame_valid => frame_valid,
                 line_valid  => line_valid,
                 data        => data);

    sim : process
        procedure async_reset is
        begin
            wait until rising_edge(clk);
            wait for CLK_PERIOD / 4;
            reset <= '1';

            wait for CLK_PERIOD / 2;
            reset <= '0';
        end procedure async_reset;

        procedure write_register(constant ofst : in std_logic_vector;
                                 constant val  : in natural) is
        begin
            wait until falling_edge(clk);
            addr   <= ofst;
            write  <= '1';
            wrdata <= std_logic_vector(to_unsigned(val, wrdata'length));

            wait until falling_edge(clk);
            addr   <= (others => '0');
            write  <= '0';
            wrdata <= (others => '0');
        end procedure write_register;

        procedure write_register(constant ofst : in std_logic_vector;
                                 constant val  : in std_logic_vector) is
        begin
            wait until falling_edge(clk);
            addr   <= ofst;
            write  <= '1';
            wrdata <= std_logic_vector(resize(unsigned(val), wrdata'length));

            wait until falling_edge(clk);
            addr   <= (others => '0');
            write  <= '0';
            wrdata <= (others => '0');
        end procedure write_register;

        procedure read_register(constant ofst : in std_logic_vector) is
        begin
            wait until falling_edge(clk);
            addr <= ofst;
            read <= '1';

            wait until falling_edge(clk);
            addr <= (others => '0');
            read <= '0';
        end procedure read_register;

        procedure check_idle is
        begin
            read_register(CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST);
            assert rddata = CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_IDLE report "Error: unit should be idle, but is busy" severity error;
        end procedure check_idle;

        procedure check_busy is
        begin
            read_register(CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST);
            assert rddata = CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_BUSY report "Error: unit should be busy, but is idle" severity error;
        end procedure check_busy;

        procedure wait_clock_cycles(constant count : in positive) is
        begin
            wait for count * CLK_PERIOD;
        end procedure wait_clock_cycles;
    begin
        async_reset;

        -- configure
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST, FRAME_WIDTH);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST, FRAME_HEIGHT);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST, FRAME_FRAME_BLANK);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_OFST, FRAME_LINE_BLANK);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST, LINE_LINE_BLANK);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_OFST, LINE_FRAME_BLANK);

        -- start generator
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST, CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_START);
        check_busy;

        wait until falling_edge(frame_valid);
        wait until falling_edge(clk);

        sim_finished <= true;
        wait;
    end process sim;

end architecture test;
