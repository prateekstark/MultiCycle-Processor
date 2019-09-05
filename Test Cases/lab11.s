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
