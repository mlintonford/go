TEXT	main(SB),512|7,$0
	CMP	R1, R2
	SUBCC	R1, R2, ZR
	BLE	ICC, label
	MOVD	$1, R1
	RET
label:
	MOVD	$2, R1
	CMP	$0, R4
	CMP ZR, R4
	CMP	$42, R2
	SUBCC	$42, R2, ZR
	RET