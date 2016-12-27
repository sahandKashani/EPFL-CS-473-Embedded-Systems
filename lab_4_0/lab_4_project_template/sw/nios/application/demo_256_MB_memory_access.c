#include <assert.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#include "io.h"
#include "system.h"

#define HPS_0_BRIDGES_BASE (0x0000)            /* address_span_expander base address from system.h (ADAPT TO YOUR DESIGN) */
#define HPS_0_BRIDGES_SPAN (256 * 1024 * 1024) /* address_span_expander span from system.h (ADAPT TO YOUR DESIGN) */

#define ONE_MB (1024 * 1024)

int main(void) {
    uint32_t megabyte_count = 0;

    for (uint32_t i = 0; i < HPS_0_BRIDGES_SPAN; i += sizeof(uint32_t)) {

        // Print progress through 256 MB memory available through address span expander
        if ((i % ONE_MB) == 0) {
            printf("megabyte_count = %" PRIu32 "\n", megabyte_count);
            megabyte_count++;
        }

        uint32_t addr = HPS_0_BRIDGES_BASE + i;

        // Write through address span expander
        uint32_t writedata = i;
        IOWR_32DIRECT(addr, 0, writedata);

        // Read through address span expander
        uint32_t readdata = IORD_32DIRECT(addr, 0);

        // Check if read data is equal to written data
        assert(writedata == readdata);
    }

    return EXIT_SUCCESS;
}
