mov r0, #-1
mov r1, #20
mov r2, #30
mov r3, #4
mov r6, #3
mul r2, r1, r2
umull r5, r6, r1, r2
mov r1, #0xf0000000
mov r2, #0x0f000000
mul r7, r2, r0
mov r2, r7
umull r5, r6, r1, r2
mul r7, r2, r0
mov r2, r7
umull r5, r6, r1, r2
smull r5, r6, r1, r2
umlal r5, r6, r1, r2
mov r2, #30
mla r1, r2, r3, r1
