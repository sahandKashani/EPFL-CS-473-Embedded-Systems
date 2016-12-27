#ifndef __CMOS_SENSOR_OUTPUT_GENERATOR_H__
#define __CMOS_SENSOR_OUTPUT_GENERATOR_H__

#if defined(__KERNEL__) || defined(MODULE)
#include <linux/types.h>
#else
#include <stdbool.h>
#include <stdint.h>
#endif

/* cmos_sensor_output_generator device structure */
typedef struct cmos_sensor_output_generator_dev {
    void     *base;      /* Base address of component */
    uint8_t  pix_depth;  /* Depth of each pixel sample */
    uint32_t max_width;  /* Maximum output frame width */
    uint32_t max_height; /* Maximum output frame height */
} cmos_sensor_output_generator_dev;

/*******************************************************************************
 *  Public API
 ******************************************************************************/
cmos_sensor_output_generator_dev cmos_sensor_output_generator_inst(void *base, uint8_t pix_depth, uint32_t max_width, uint32_t max_height);

/*
 * Helper macro for easily constructing device structures. The user needs to
 * provide the component's prefix, and the corresponding device structure is
 * returned.
 */
#define CMOS_SENSOR_OUTPUT_GENERATOR_INST(prefix)                 \
    cmos_sensor_output_generator_inst(((void *) prefix ## _BASE), \
                                      prefix ## _PIX_DEPTH,       \
                                      prefix ## _MAX_WIDTH,       \
                                      prefix ## _MAX_HEIGHT)

void cmos_sensor_output_generator_init(cmos_sensor_output_generator_dev *dev);

bool cmos_sensor_output_generator_configure(cmos_sensor_output_generator_dev *dev, uint32_t frame_width, uint32_t frame_height, uint32_t frame_frame_blank, uint32_t frame_line_blank, uint32_t line_line_blank, uint32_t line_frame_blank);
void cmos_sensor_output_generator_start(cmos_sensor_output_generator_dev *dev);
void cmos_sensor_output_generator_stop(cmos_sensor_output_generator_dev *dev);

#endif /* __CMOS_SENSOR_OUTPUT_GENERATOR_H__ */

