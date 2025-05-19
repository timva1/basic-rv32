# SRAM initialization
# Format
# addr 0x0 - 0xF | init to 0x0, reserved for test results
# addr 0x10 | init to sum of correct test results minus 1
# addr 0x11 - 0x2F | init to initial register values
# ... | init to 0x0, miscellaneous

contents = 1024 * [8 * "0"]

# initial register values
contents[0x11] = "00000001" # x1
contents[0x12] = "00000002" # x2
contents[0x13] = "00000004" # x3
contents[0x14] = "00000008" # x4
contents[0x15] = "00000010" # x5
contents[0x16] = "00000020" # x6
contents[0x17] = "FFFFFFFF" # x7
contents[0x18] = "FFFFFFFE" # x8
contents[0x19] = "FFFFFFFC" # x9
contents[0x1A] = "FFFFFFF8" # x10
contents[0x1B] = "FFFFFFF0" # x11
contents[0x1C] = "FFFFFFE0" # x12
contents[0x1D] = "FFFFFFC0" # x13
contents[0x1E] = "00000003" # x14
contents[0x1F] = "00000004" # x15
contents[0x20] = "00000005" # x16
contents[0x21] = "00000006" # x17
contents[0x22] = "00000007" # x18
# rest initialized to 0x0

with open("bin/tests/shifts/init_sram.mem", "w") as f:
    for i in range(1024):
        f.write(contents[i] + "\n")
    