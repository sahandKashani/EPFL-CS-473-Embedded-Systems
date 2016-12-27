library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cmos_sensor_output_generator_constants.all;

entity cmos_sensor_output_generator is
    generic(
        PIX_DEPTH  : positive;
        MAX_WIDTH  : positive;
        MAX_HEIGHT : positive
    );
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Avalon-MM slave
        addr        : in  std_logic_vector(2 downto 0);
        read        : in  std_logic;
        write       : in  std_logic;
        rddata      : out std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);
        wrdata      : in  std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);

        frame_valid : out std_logic;
        line_valid  : out std_logic;
        data        : out std_logic_vector(PIX_DEPTH - 1 downto 0)
    );
end entity cmos_sensor_output_generator;

architecture rtl of cmos_sensor_output_generator is
    constant CONFIG_REG_WIDTH : positive := bit_width(max(MAX_WIDTH, MAX_HEIGHT));

    -- MM_WRITE
    signal reg_frame_width_config       : unsigned(CONFIG_REG_WIDTH - 1 downto 0);
    signal reg_frame_height_config      : unsigned(CONFIG_REG_WIDTH - 1 downto 0);
    signal reg_frame_frame_blank_config : unsigned(CONFIG_REG_WIDTH - 1 downto 0);
    signal reg_frame_line_blank_config  : unsigned(CONFIG_REG_WIDTH - 1 downto 0);
    signal reg_line_line_blank_config   : unsigned(CONFIG_REG_WIDTH - 1 downto 0);
    signal reg_line_frame_blank_config  : unsigned(CONFIG_REG_WIDTH - 1 downto 0);
    signal reg_start                    : std_logic;
    signal reg_stop                     : std_logic;

    -- STATE_LOGIC & NEXT_STATE_LOGIC
    type state_type is (STATE_IDLE, STATE_FRAME_FRAME_BLANK, STATE_FRAME_LINE_BLANK, STATE_VALID, STATE_LINE_LINE_BLANK, STATE_LINE_FRAME_BLANK);
    signal reg_state, next_reg_state                                         : state_type;
    signal reg_frame_width_counter, next_reg_frame_width_counter             : unsigned(reg_frame_width_config'range);
    signal reg_frame_height_counter, next_reg_frame_height_counter           : unsigned(reg_frame_height_config'range);
    signal reg_frame_frame_blank_counter, next_reg_frame_frame_blank_counter : unsigned(reg_frame_frame_blank_config'range);
    signal reg_frame_line_blank_counter, next_reg_frame_line_blank_counter   : unsigned(reg_frame_line_blank_config'range);
    signal reg_line_line_blank_counter, next_reg_line_line_blank_counter     : unsigned(reg_line_line_blank_config'range);
    signal reg_line_frame_blank_counter, next_reg_line_frame_blank_counter   : unsigned(reg_line_frame_blank_config'range);

begin
    MM_WRITE : process(clk, reset)
    begin
        if reset = '1' then
            reg_frame_width_config       <= to_unsigned(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_MIN, reg_frame_width_config'length);
            reg_frame_height_config      <= to_unsigned(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_MIN, reg_frame_height_config'length);
            reg_frame_frame_blank_config <= to_unsigned(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_MIN, reg_frame_frame_blank_config'length);
            reg_frame_line_blank_config  <= to_unsigned(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_MIN, reg_frame_line_blank_config'length);
            reg_line_line_blank_config   <= to_unsigned(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_MIN, reg_line_line_blank_config'length);
            reg_line_frame_blank_config  <= to_unsigned(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_MIN, reg_line_frame_blank_config'length);
            reg_start                    <= '0';
            reg_stop                     <= '0';

        elsif rising_edge(clk) then
            reg_start <= '0';
            reg_stop  <= '0';

            if write = '1' then
                case addr is
                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST =>
                        if reg_state = STATE_IDLE then
                            reg_frame_width_config <= unsigned(wrdata(reg_frame_width_config'range));
                        end if;

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST =>
                        if reg_state = STATE_IDLE then
                            reg_frame_height_config <= unsigned(wrdata(reg_frame_height_config'range));
                        end if;

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST =>
                        if reg_state = STATE_IDLE then
                            reg_frame_frame_blank_config <= unsigned(wrdata(reg_frame_frame_blank_config'range));
                        end if;

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_OFST =>
                        if reg_state = STATE_IDLE then
                            reg_frame_line_blank_config <= unsigned(wrdata(reg_frame_line_blank_config'range));
                        end if;

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST =>
                        if reg_state = STATE_IDLE then
                            reg_line_line_blank_config <= unsigned(wrdata(reg_line_line_blank_config'range));
                        end if;

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_OFST =>
                        if reg_state = STATE_IDLE then
                            reg_line_frame_blank_config <= unsigned(wrdata(reg_line_frame_blank_config'range));
                        end if;

                    when CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST =>
                        if wrdata(CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_WIDTH - 1 downto 0) = CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_START then
                            if reg_state = STATE_IDLE then
                                reg_start <= '1';
                            end if;

                        elsif wrdata(CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_WIDTH - 1 downto 0) = CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_STOP then
                            if reg_state /= STATE_IDLE then
                                reg_stop <= '1';
                            end if;
                        end if;
                    when others =>
                end case;
            end if;
        end if;
    end process;

    MM_READ : process(clk, reset)
    begin
        if reset = '1' then
            rddata <= (others => '0');

        elsif rising_edge(clk) then
            rddata <= (others => '0');

            if read = '1' then
                case addr is
                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST =>
                        rddata <= std_logic_vector(resize(reg_frame_width_config, rddata'length));

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST =>
                        rddata <= std_logic_vector(resize(reg_frame_height_config, rddata'length));

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST =>
                        rddata <= std_logic_vector(resize(reg_frame_frame_blank_config, rddata'length));

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_OFST =>
                        rddata <= std_logic_vector(resize(reg_frame_line_blank_config, rddata'length));

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST =>
                        rddata <= std_logic_vector(resize(reg_line_line_blank_config, rddata'length));

                    when CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_OFST =>
                        rddata <= std_logic_vector(resize(reg_line_frame_blank_config, rddata'length));

                    when CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST =>
                        if reg_state = STATE_IDLE then
                            rddata <= CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_IDLE;

                        else
                            rddata <= CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_BUSY;
                        end if;

                    when others =>
                        null;
                end case;

            end if;
        end if;
    end process;

    STATE_LOGIC : process(clk, reset)
    begin
        if reset = '1' then
            reg_state                     <= STATE_IDLE;
            reg_frame_width_counter       <= (others => '0');
            reg_frame_height_counter      <= (others => '0');
            reg_frame_frame_blank_counter <= (others => '0');
            reg_frame_line_blank_counter  <= (others => '0');
            reg_line_line_blank_counter   <= (others => '0');
            reg_line_frame_blank_counter  <= (others => '0');

        elsif rising_edge(clk) then
            reg_state                     <= next_reg_state;
            reg_frame_width_counter       <= next_reg_frame_width_counter;
            reg_frame_height_counter      <= next_reg_frame_height_counter;
            reg_frame_frame_blank_counter <= next_reg_frame_frame_blank_counter;
            reg_frame_line_blank_counter  <= next_reg_frame_line_blank_counter;
            reg_line_line_blank_counter   <= next_reg_line_line_blank_counter;
            reg_line_frame_blank_counter  <= next_reg_line_frame_blank_counter;
        end if;
    end process;

    NEXT_STATE_LOGIC : process(reg_frame_frame_blank_config, reg_frame_frame_blank_counter, reg_frame_height_config, reg_frame_height_counter, reg_frame_line_blank_config, reg_frame_line_blank_counter, reg_frame_width_config, reg_frame_width_counter, reg_line_frame_blank_config, reg_line_frame_blank_counter, reg_line_line_blank_config, reg_line_line_blank_counter, reg_start, reg_state, reg_stop)
    begin
        next_reg_state                     <= reg_state;
        next_reg_frame_width_counter       <= reg_frame_width_counter;
        next_reg_frame_height_counter      <= reg_frame_height_counter;
        next_reg_frame_frame_blank_counter <= reg_frame_frame_blank_counter;
        next_reg_frame_line_blank_counter  <= reg_frame_line_blank_counter;
        next_reg_line_line_blank_counter   <= reg_line_line_blank_counter;
        next_reg_line_frame_blank_counter  <= reg_line_frame_blank_counter;

        frame_valid <= '0';
        line_valid  <= '0';
        data        <= (others => '0');

        case reg_state is
            when STATE_IDLE =>
                if reg_start = '1' then
                    if reg_frame_line_blank_config > 0 then
                        next_reg_state                    <= STATE_FRAME_LINE_BLANK;
                        next_reg_frame_line_blank_counter <= to_unsigned(1, next_reg_frame_line_blank_counter'length);

                    elsif reg_frame_line_blank_config = 0 then
                        next_reg_state                <= STATE_VALID;
                        next_reg_frame_width_counter  <= to_unsigned(1, next_reg_frame_width_counter'length);
                        next_reg_frame_height_counter <= to_unsigned(1, next_reg_frame_height_counter'length);
                    end if;
                end if;

            when STATE_FRAME_FRAME_BLANK =>
                next_reg_frame_frame_blank_counter <= reg_frame_frame_blank_counter + 1;

                if reg_stop = '1' then
                    next_reg_state <= STATE_IDLE;

                else
                    if reg_frame_frame_blank_counter = reg_frame_frame_blank_config then
                        if reg_frame_line_blank_config > 0 then
                            next_reg_state                    <= STATE_FRAME_LINE_BLANK;
                            next_reg_frame_line_blank_counter <= to_unsigned(1, next_reg_frame_line_blank_counter'length);

                        elsif reg_frame_line_blank_config = 0 then
                            next_reg_state                <= STATE_VALID;
                            next_reg_frame_width_counter  <= to_unsigned(1, next_reg_frame_width_counter'length);
                            next_reg_frame_height_counter <= to_unsigned(1, next_reg_frame_height_counter'length);
                        end if;
                    end if;
                end if;

            when STATE_FRAME_LINE_BLANK =>
                frame_valid <= '1';

                next_reg_frame_line_blank_counter <= reg_frame_line_blank_counter + 1;

                if reg_stop = '1' then
                    next_reg_state <= STATE_IDLE;

                else
                    if reg_frame_line_blank_counter = reg_frame_line_blank_config then
                        next_reg_state                <= STATE_VALID;
                        next_reg_frame_width_counter  <= to_unsigned(1, next_reg_frame_width_counter'length);
                        next_reg_frame_height_counter <= to_unsigned(1, next_reg_frame_height_counter'length);
                    end if;
                end if;

            when STATE_VALID =>
                frame_valid <= '1';
                line_valid  <= '1';
                data        <= std_logic_vector(resize((reg_frame_height_counter - 1) * reg_frame_width_config + (reg_frame_width_counter - 1), data'length));

                -- if reg_frame_height_counter(0) = '0' and reg_frame_width_counter(0) = '0' then -- upper right
                --     data <= std_logic_vector(to_unsigned(1, data'length));
                -- end if;
                --
                -- if reg_frame_height_counter(0) = '0' and reg_frame_width_counter(0) = '1' then -- upper left
                --     data <= std_logic_vector(to_unsigned(2, data'length));
                -- end if;
                --
                -- if reg_frame_height_counter(0) = '1' and reg_frame_width_counter(0) = '0' then -- lower right
                --     data <= std_logic_vector(to_unsigned(2, data'length));
                -- end if;
                --
                -- if reg_frame_height_counter(0) = '1' and reg_frame_width_counter(0) = '1' then -- lower left
                --     data <= std_logic_vector(to_unsigned(3, data'length));
                -- end if;

                next_reg_frame_width_counter <= reg_frame_width_counter + 1;

                if reg_stop = '1' then
                    next_reg_state <= STATE_IDLE;

                else
                    if reg_frame_width_counter = reg_frame_width_config then
                        if reg_frame_height_counter < reg_frame_height_config then
                            next_reg_state                   <= STATE_LINE_LINE_BLANK;
                            next_reg_line_line_blank_counter <= to_unsigned(1, next_reg_line_line_blank_counter'length);

                        elsif reg_frame_height_counter = reg_frame_height_config then
                            if reg_line_frame_blank_config > 0 then
                                next_reg_state                    <= STATE_LINE_FRAME_BLANK;
                                next_reg_line_frame_blank_counter <= to_unsigned(1, next_reg_line_frame_blank_counter'length);

                            elsif reg_line_frame_blank_config = 0 then
                                next_reg_state                     <= STATE_FRAME_FRAME_BLANK;
                                next_reg_frame_frame_blank_counter <= to_unsigned(1, next_reg_frame_frame_blank_counter'length);
                            end if;
                        end if;
                    end if;
                end if;

            when STATE_LINE_LINE_BLANK =>
                frame_valid <= '1';

                next_reg_line_line_blank_counter <= reg_line_line_blank_counter + 1;

                if reg_stop = '1' then
                    next_reg_state <= STATE_IDLE;

                else
                    if reg_line_line_blank_counter = reg_line_line_blank_config then
                        next_reg_state                <= STATE_VALID;
                        next_reg_frame_width_counter  <= to_unsigned(1, next_reg_frame_width_counter'length);
                        next_reg_frame_height_counter <= reg_frame_height_counter + 1;
                    end if;
                end if;

            when STATE_LINE_FRAME_BLANK =>
                frame_valid <= '1';

                next_reg_line_frame_blank_counter <= reg_line_frame_blank_counter + 1;

                if reg_stop = '1' then
                    next_reg_state <= STATE_IDLE;

                else
                    if reg_line_frame_blank_counter = reg_line_frame_blank_config then
                        next_reg_state                     <= STATE_FRAME_FRAME_BLANK;
                        next_reg_frame_frame_blank_counter <= to_unsigned(1, next_reg_frame_frame_blank_counter'length);
                    end if;
                end if;
        end case;
    end process;

end architecture rtl;
