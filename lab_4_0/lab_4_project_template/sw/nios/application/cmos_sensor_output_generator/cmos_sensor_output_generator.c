#if defined(__KERNEL__) || defined(MODULE)
#include <linux/types.h>
#else
#include <stdint.h>
#include <stdbool.h>
#endif

#include "cmos_sensor_output_generator.h"
#include "cmos_sensor_output_generator_regs.h"

/*******************************************************************************
 *  Private API
 ******************************************************************************/
static uint32_t max(uint32_t a, uint32_t b);
static bool write_frame_width_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_width);
static bool write_frame_height_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_height);
static bool write_frame_frame_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_frame_blank);
static bool write_frame_line_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_line_blank);
static bool write_line_line_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t line_line_blank);
static bool write_line_frame_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t line_frame_blank);
static uint32_t read_frame_width_reg(cmos_sensor_output_generator_dev *dev);
static uint32_t read_frame_height_reg(cmos_sensor_output_generator_dev *dev);
static uint32_t read_frame_frame_blank_reg(cmos_sensor_output_generator_dev *dev);
static uint32_t read_frame_line_blank_reg(cmos_sensor_output_generator_dev *dev);
static uint32_t read_line_line_blank_reg(cmos_sensor_output_generator_dev *dev);
static uint32_t read_line_frame_blank_reg(cmos_sensor_output_generator_dev *dev);
static bool is_idle(cmos_sensor_output_generator_dev *dev);

/*
 * max
 *
 * Computes the max between two 32-bit unsigned numbers.
 */
static uint32_t max(uint32_t a, uint32_t b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

/*
 * write_frame_width_reg
 *
 * Writes the supplied value to the CONFIG_FRAME_WIDTH register.
 *
 * Returns true if successful (value within legal bounds) and false otherwise.
 */
static bool write_frame_width_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_width) {
    uint32_t max_reg_value = max(dev->max_width, dev->max_height);

    bool lower_bound_valid = CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_MIN <= frame_width;
    bool upper_bound_valid = frame_width <= max_reg_value;

    bool valid = lower_bound_valid && upper_bound_valid && is_idle(dev);

    if (valid) {
        CMOS_SENSOR_OUTPUT_GENERATOR_WR_CONFIG_FRAME_WIDTH(dev->base, frame_width);
        return true;
    } else {
        return false;
    }
}

/*
 * write_frame_height_reg
 *
 * Writes the supplied value to the CONFIG_FRAME_HEIGHT register.
 *
 * Returns true if successful (value within legal bounds) and false otherwise.
 */
static bool write_frame_height_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_height) {
    uint32_t max_reg_value = max(dev->max_width, dev->max_height);

    bool lower_bound_valid = CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_MIN <= frame_height;
    bool upper_bound_valid = frame_height <= max_reg_value;

    bool valid = lower_bound_valid && upper_bound_valid && is_idle(dev);

    if (valid) {
        CMOS_SENSOR_OUTPUT_GENERATOR_WR_CONFIG_FRAME_HEIGHT(dev->base, frame_height);
        return true;
    } else {
        return false;
    }
}

/*
 * write_frame_frame_blank_reg
 *
 * Writes the supplied value to the CONFIG_FRAME_FRAME_BLANK register.
 *
 * Returns true if successful (value within legal bounds) and false otherwise.
 */
static bool write_frame_frame_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_frame_blank) {
    uint32_t max_reg_value = max(dev->max_width, dev->max_height);

    bool lower_bound_valid = CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_MIN <= frame_frame_blank;
    bool upper_bound_valid = frame_frame_blank <= max_reg_value;

    bool valid = lower_bound_valid && upper_bound_valid && is_idle(dev);

    if (valid) {
        CMOS_SENSOR_OUTPUT_GENERATOR_WR_CONFIG_FRAME_FRAME_BLANK(dev->base, frame_frame_blank);
        return true;
    } else {
        return false;
    }
}

/*
 * write_frame_line_blank_reg
 *
 * Writes the supplied value to the CONFIG_FRAME_LINE_BLANK register.
 *
 * Returns true if successful (value within legal bounds) and false otherwise.
 */
static bool write_frame_line_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t frame_line_blank) {
    uint32_t max_reg_value = max(dev->max_width, dev->max_height);

    bool lower_bound_valid = CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_MIN <= frame_line_blank;
    bool upper_bound_valid = frame_line_blank <= max_reg_value;

    bool valid = lower_bound_valid && upper_bound_valid && is_idle(dev);

    if (valid) {
        CMOS_SENSOR_OUTPUT_GENERATOR_WR_CONFIG_FRAME_LINE_BLANK(dev->base, frame_line_blank);
        return true;
    } else {
        return false;
    }
}

/*
 * write_line_line_blank_reg
 *
 * Writes the supplied value to the CONFIG_LINE_LINE_BLANK register.
 *
 * Returns true if successful (value within legal bounds) and false otherwise.
 */
static bool write_line_line_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t line_line_blank) {
    uint32_t max_reg_value = max(dev->max_width, dev->max_height);

    bool lower_bound_valid = CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_MIN <= line_line_blank;
    bool upper_bound_valid = line_line_blank <= max_reg_value;

    bool valid = lower_bound_valid && upper_bound_valid && is_idle(dev);

    if (valid) {
        CMOS_SENSOR_OUTPUT_GENERATOR_WR_CONFIG_LINE_LINE_BLANK(dev->base, line_line_blank);
        return true;
    } else {
        return false;
    }
}

/*
 * write_line_frame_blank_reg
 *
 * Writes the supplied value to the CONFIG_LINE_FRAME_BLANK register.
 *
 * Returns true if successful (value within legal bounds) and false otherwise.
 */
static bool write_line_frame_blank_reg(cmos_sensor_output_generator_dev *dev, uint32_t line_frame_blank) {
    uint32_t max_reg_value = max(dev->max_width, dev->max_height);

    bool lower_bound_valid = CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_MIN <= line_frame_blank;
    bool upper_bound_valid = line_frame_blank <= max_reg_value;

    bool valid = lower_bound_valid && upper_bound_valid && is_idle(dev);

    if (valid) {
        CMOS_SENSOR_OUTPUT_GENERATOR_WR_CONFIG_LINE_FRAME_BLANK(dev->base, line_frame_blank);
        return true;
    } else {
        return false;
    }
}

/*
 * read_frame_width_reg
 *
 * Reads and returns the contents of the CONFIG_FRAME_WIDTH register
 */
static uint32_t read_frame_width_reg(cmos_sensor_output_generator_dev *dev) {
    return CMOS_SENSOR_OUTPUT_GENERATOR_RD_CONFIG_FRAME_WIDTH(dev->base);
}

/*
 * read_frame_height_reg
 *
 * Reads and returns the contents of the CONFIG_FRAME_HEIGHT register
 */
static uint32_t read_frame_height_reg(cmos_sensor_output_generator_dev *dev) {
    return CMOS_SENSOR_OUTPUT_GENERATOR_RD_CONFIG_FRAME_HEIGHT(dev->base);
}

/*
 * read_frame_frame_blank_reg
 *
 * Reads and returns the contents of the CONFIG_FRAME_FRAME_BLANK register
 */
static uint32_t read_frame_frame_blank_reg(cmos_sensor_output_generator_dev *dev) {
    return CMOS_SENSOR_OUTPUT_GENERATOR_RD_CONFIG_FRAME_FRAME_BLANK(dev->base);
}

/*
 * read_frame_line_blank_reg
 *
 * Reads and returns the contents of the CONFIG_FRAME_LINE_BLANK register
 */
static uint32_t read_frame_line_blank_reg(cmos_sensor_output_generator_dev *dev) {
    return CMOS_SENSOR_OUTPUT_GENERATOR_RD_CONFIG_FRAME_LINE_BLANK(dev->base);
}

/*
 * read_line_line_blank_reg
 *
 * Reads and returns the contents of the CONFIG_LINE_LINE_BLANK register
 */
static uint32_t read_line_line_blank_reg(cmos_sensor_output_generator_dev *dev) {
    return CMOS_SENSOR_OUTPUT_GENERATOR_RD_CONFIG_LINE_LINE_BLANK(dev->base);
}

/*
 * read_line_frame_blank_reg
 *
 * Reads and returns the contents of the CONFIG_LINE_FRAME_BLANK register
 */
static uint32_t read_line_frame_blank_reg(cmos_sensor_output_generator_dev *dev) {
    return CMOS_SENSOR_OUTPUT_GENERATOR_RD_CONFIG_LINE_FRAME_BLANK(dev->base);
}

/*
 * is_idle
 *
 * Returns true if the controller is idle, and false otherwise.
 */
static bool is_idle(cmos_sensor_output_generator_dev *dev) {
    return CMOS_SENSOR_OUTPUT_GENERATOR_RD_STATUS(dev->base) == CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_IDLE;
}

/*******************************************************************************
 *  Public API
 ******************************************************************************/
/*
 * cmos_sensor_output_generator_inst
 *
 * Constructs a device structure.
 */
cmos_sensor_output_generator_dev cmos_sensor_output_generator_inst(void *base, uint8_t pix_depth, uint32_t max_width, uint32_t max_height) {
    cmos_sensor_output_generator_dev dev;

    dev.base = base;
    dev.pix_depth = pix_depth;
    dev.max_width = max_width;
    dev.max_height = max_height;

    return dev;
}

/*
 * cmos_sensor_output_generator_init
 *
 * Initializes the CMOS Sensor Output Generator controller.
 *
 * This routine sets the values of all registers to the minimums defined in
 * cmos_sensor_output_generator_regs.h.
 */
void cmos_sensor_output_generator_init(cmos_sensor_output_generator_dev *dev) {
    cmos_sensor_output_generator_stop(dev);

    write_frame_width_reg(dev, CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_MIN);
    write_frame_height_reg(dev, CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_MIN);
    write_frame_frame_blank_reg(dev, CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_MIN);
    write_frame_line_blank_reg(dev, CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_MIN);
    write_line_line_blank_reg(dev, CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_MIN);
    write_line_frame_blank_reg(dev, CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_MIN);
}

/*
 * cmos_sensor_output_generator_configure
 *
 * Configure the generator.
 *
 * Returns true if successful (values within bounds), and false otherwise.
 */
bool cmos_sensor_output_generator_configure(cmos_sensor_output_generator_dev *dev, uint32_t frame_width, uint32_t frame_height, uint32_t frame_frame_blank, uint32_t frame_line_blank, uint32_t line_line_blank, uint32_t line_frame_blank) {
    bool success = true;

    cmos_sensor_output_generator_stop(dev);

    success &= write_frame_width_reg(dev, frame_width);
    success &= write_frame_height_reg(dev, frame_height);
    success &= write_frame_frame_blank_reg(dev, frame_frame_blank);
    success &= write_frame_line_blank_reg(dev, frame_line_blank);
    success &= write_line_line_blank_reg(dev, line_line_blank);
    success &= write_line_frame_blank_reg(dev, line_frame_blank);

    return success;
}

/*
 * cmos_sensor_output_generator_start
 *
 * Starts the generator.
 *
 * You must previously configure the controller by calling
 * cmos_sensor_output_generator_configure() before calling this function.
 */
void cmos_sensor_output_generator_start(cmos_sensor_output_generator_dev *dev) {
    CMOS_SENSOR_OUTPUT_GENERATOR_WR_COMMAND(dev->base, CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_START);
}

/*
 * cmos_sensor_output_generator_stop
 *
 * Stops the generator.
 */
void cmos_sensor_output_generator_stop(cmos_sensor_output_generator_dev *dev) {
    CMOS_SENSOR_OUTPUT_GENERATOR_WR_COMMAND(dev->base, CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_STOP);
}
