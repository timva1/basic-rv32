# SRAM initialization
# Format
# addr 0x0 - 0xF | init to 0x0, reserved for test results
# addr 0x10 | init to sum of correct test results minus 1
# addr 0x11 - 0x2F | init to initial register values
# ... | init to 0x0, miscellaneous

contents = 1024 * [8 * "0"]

# test ref value
contents[0x10] = "0000063B"

# initial register values
contents[0x11] = "00000000" # x1
contents[0x12] = "00000001" # x2
# rest initialized to 0x0

with open("bin/tests/fibonacci/init_sram.mem", "w") as f:
    for i in range(1024):
        f.write(contents[i] + "\n")
    