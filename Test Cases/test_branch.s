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

