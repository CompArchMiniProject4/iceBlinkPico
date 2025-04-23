j start
labelEr:
    addi x1, x0, 0
    sw x1, 252(x0)      # Error handler
start:
    lui x1, 1           # x1 = 0x1000
    addi x2, x0, 2      # x2 = 2
    addi x3, x0, -3     # x3 = -3
    bge x2, x3, label1  # Taken (2 >= -3)
    addi x1, x0, 0
    sw x1, 252(x0)
label1:
    sltu x4, x2, x3     # x4 = 1 (2 < -3 unsigned)
    bne x4, x2, label2  # Taken (1 != 2)
    addi x1, x0, 0
    sw x1, 252(x0)
label2:
    xor x5, x2, x3      # x5 = 0xFFFFFFFF
    blt x5, x3, labelEr # Not taken (-1 > -3)
    sltu x6, x5, x3     # x6 = 0
    bltu x2, x5, label3 # Taken (2 < 0xFFFFFFFF)
    addi x1, x0, 0
    sw x1, 252(x0)
label3:
    slli x7, x5, 4      # x7 = 0xFFFFFFF0
    bgeu x5, x7, label4 # Taken (0xFFFFFFFF >= 0xFFFFFFF0)
    addi x1, x0, 0
    sw x1, 252(x0)
label4:
    srai x1, x1, 2      # x1 = 0x400
    sltiu x1, x1, -2048 # x1 = 1 (0x400 < 0xFFFFF800)
    slli x1, x1, 13     # x1 = 0x2000
    srli x1, x1, 1      # x1 = 0x1000
    srai x7, x7, 4      # x7 = 0xFFFFFFFF
    xori x7, x7, -1     # x7 = 0
    addi x7, x7, 176    # x7 = 176 (0xB0)
    bge x5, x5, label5  # Taken (-1 >= -1)
    addi x1, x0, 0
    sw x1, 252(x0)
label5:
    bge x3, x0, labelEr # Not taken (-3 >= 0)
    bgeu x5, x5, label6 # Taken (0xFFFFFFFF >= 0xFFFFFFFF)
    addi x1, x0, 0
    sw x1, 252(x0)
label6:
    blt x5, x0, label7  # Taken (-1 < 0)
    addi x1, x0, 0
    sw x1, 252(x0)
label7:
    bltu x5, x0, labelEr # Not taken (0xFFFFFFFF > 0)
    bgeu x0, x5, labelEr # Not taken (0 < 0xFFFFFFFF)
    jalr x8, x7, 0      # Jump to 0xB0 (test end)
    addi x1, x0, 0
    sw x1, 252(x0)