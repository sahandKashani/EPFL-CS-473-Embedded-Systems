#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#include "cmos_sensor_output_generator/cmos_sensor_output_generator.h"
#include "cmos_sensor_output_generator/cmos_sensor_output_generator_regs.h"

#define CMOS_SENSOR_OUTPUT_GENERATOR_0_BASE       (0x0000) /* cmos_sensor_output_generator base address from system.h (ADAPT TO YOUR DESIGN) */
#define CMOS_SENSOR_OUTPUT_GENERATOR_0_PIX_DEPTH  (12)     /* cmos_sensor_output_generator pix depth from system.h (ADAPT TO YOUR DESIGN) */
#define CMOS_SENSOR_OUTPUT_GENERATOR_0_MAX_WIDTH  (640)    /* cmos_sensor_output_generator max width from system.h (ADAPT TO YOUR DESIGN) */
#define CMOS_SENSOR_OUTPUT_GENERATOR_0_MAX_HEIGHT (480)    /* cmos_sensor_output_generator max height from system.h (ADAPT TO YOUR DESIGN) */

int main(void) {
    cmos_sensor_output_generator_dev cmos_sensor_output_generator = cmos_sensor_output_generator_inst(CMOS_SENSOR_OUTPUT_GENERATOR_0_BASE,
                                                                                                      CMOS_SENSOR_OUTPUT_GENERATOR_0_PIX_DEPTH,
                                                                                                      CMOS_SENSOR_OUTPUT_GENERATOR_0_MAX_WIDTH,
                                                                                                      CMOS_SENSOR_OUTPUT_GENERATOR_0_MAX_HEIGHT);
    cmos_sensor_output_generator_init(&cmos_sensor_output_generator);

    cmos_sensor_output_generator_stop(&cmos_sensor_output_generator);

    cmos_sensor_output_generator_configure(&cmos_sensor_output_generator,
                                           480,
                                           640,
                                           CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_MIN,
                                           CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_MIN,
                                           CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_MIN,
                                           CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_MIN);

    cmos_sensor_output_generator_start(&cmos_sensor_output_generator);

    return EXIT_SUCCESS;
}
