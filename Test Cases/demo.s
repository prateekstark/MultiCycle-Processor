Program0:
;; Fibonacci number
	mov r1, #0
	mov r2, #1
	mov r3, #0
	mov r4, #0
	add r4, r4, #8
	mov r5, #100
	str r1, [r5, #0]
	str r2, [r5, #4]
Fib: 	
	add r3, r1, r2
	mov r1, r2
	mov r2, r3
	str r3, [r5, r4]
	add r4, r4, #4
	cmp r4, #40
	bne Fib	

Program1:
;; Swaps two numbers
;; Makes it 2, 3, 1
	mov r0, #1
	mov r1, #2
	mov r2, #3
	add r0, r0, r1
	sub r1, r0, r1
	sub r0, r0, r1
	add r1, r1, r2
	sub r2, r1, r2
	sub r1, r1, r2

Program2:
;; Tests all the branching, compare instructions
	mov r1, #12
	mov r2, #13
	cmp r1, #12
	beq branch1
branch2:
	b endbranch	
branch1:
	cmp r1, r2
	bne branch2
endbranch:

Program3:
;; Tests load/store instructions
mov r0, #100
mov r1, #123
str r1, [r0, #20]
add r0, r0, #40
ldr r2, [r0, #-20]

Program4:
;; Demo for Lab 8 - All DP instructions
    mov r1,#1
    mov r2,#2
    mvn r4,#0             @ mvn
    cmp r1,r2             @ cmp
    cmn r1,r2             @ cmn
    tst r1,r2             @ tst
    teq r1,r2             @ teq 
    bic r3,r1,r2          @ bic
    eor r3,r1,r2          @ eor
    and r3,r1,r2          @ and
    rsb r3,r1,r2          @ rsb
    adc r3,r1,r2          @ adc
    sbc r3,r1,r2          @ sbc
    add r3,r1,r2,LSL #2   @ shift with num
    add r3,r1,r2,ROR #2   @ rotate with num
    add r3,r1,r2,LSL r4   @ shift with register

Program5:
;; Demo for Lab 9 - Load Store
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

Program6:
;; Demo for Lab 10 - Multiplication
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

Program7:
;; Demo for Lab 11 - Predication and functions
mov r0, #1
mov r1, #2
mov r2, r1
cmp r1, r0
b after

func:
	mov r4, #5
	mul r7, r2, r0
	mov pc, lr

after:
	beq func 
	addhs r0, r1, r2
	mov r4, #4
	blne func
	mov r9, #8