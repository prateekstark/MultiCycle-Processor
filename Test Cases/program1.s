mov r0, #0xf0000000
mov r1, #0x0f000000
mov r2, #0x00f00000
add r2, r2, r1
add r1, r1, r0
mov r4, #0x000000ff
add r4, r1, r4
a: mov r5, #100
mov r6, #200
cmp r5, #100
str r4, [r5, #0]
strh r1, [r6, #0]
strb r1, [r5, #20]
ldrh r7, [r5, #0]
ldrb r8, [r5, #0]
ldrsh r7, [r6, #0]
ldrsb r8, [r5, #20]
mov r9, #25
mov r10, #0
ldr r7, [r5, r9 , LSL #4]
ldr r8, [r10, r5]!
ldr r7, [r10, #0]
ldr r7, [r5], r9, LSL#4
