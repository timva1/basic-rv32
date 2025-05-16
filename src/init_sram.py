contents = 1024 * [8 * "0"]

contents[0] = "00000005"
contents[1] = "00000085"
contents[2] = "00000006"
contents[3] = "00008006"
contents[4] = "00000007"
contents[5] = "80000007"
contents[6] = "000000FF"
contents[7] = "0000FFFF"

with open("src/exec_test_sram.mem", "w") as f:
    for i in range(1024):
        f.write(contents[i] + "\n")
    