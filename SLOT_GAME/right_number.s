.equ    GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
    .equ    GPFSEL0,    0x00       @ GPIOポートの機能を選択する番地のオフセット
    .equ    GPSET0,     0x1C       @ GPIOポートの出力値を1にするための番地のオフセット
    .equ    GPCLR0,     0x28       @ GPIOボートの出力値を0にするための番地のオフセット

    .equ    GPFSEL_VEC0, 0x01201000 @ GPFSEL0 に設定する値 (GPIO #4, #7, #8 を出力用に設定)
    .equ    GPFSEL_VEC1, 0x11249041 @ GPFSEL1 に設定する値 (GPIO #10, #12, #14, #15, #16, #17, #18 を出力用に設定)
    .equ    GPFSEL_VEC2, 0x00209249 @ GPFSEL2 に設定する値 (GPIO #20, #21, #22, #23, #24, #25, #27 を出力用に設定)
	
	.equ LED_PORT, 10

	.equ SWITCH1_PORT, 13
	.equ SWITCH2_PORT, 26
	.equ SWITCH3_PORT, 5
	.equ SWITCH4_PORT, 6
	.equ GPLEV0, 0x34

	
	.equ COL1_PORT, 27
	.equ COL2_PORT, 8
	.equ COL3_PORT, 25
	.equ COL4_PORT, 23
	.equ COL5_PORT, 24
	.equ COL6_PORT, 22
	.equ COL7_PORT, 17
	.equ COL8_PORT, 4
	.equ ROW1_PORT, 14
	.equ ROW2_PORT, 15
	.equ ROW3_PORT, 21
	.equ ROW4_PORT, 18
	.equ ROW5_PORT, 12
	.equ ROW6_PORT, 20
	.equ ROW7_PORT, 7
	.equ ROW8_PORT, 16

	.equ STACK, 0x8000

	.equ TIMER_BASE, 0x3f003000
	.equ CLO, 0x4		@フリーランニングカウンタの下位32ビット
	.equ TIMER_HZ, 1000 * 100	@1秒

    .section .text
	.global right_number,framebuf, gyou, num0, num1, num2, num3, num4, num5, num6, num7, num8, num9, endframebuf
right_number:

	str     r0, [sp, #-4]!    @ push r0
	str     r1, [sp, #-4]!    @ push r1
	str     r2, [sp, #-4]!    @ push r2
	str     r3, [sp, #-4]!    @ push r3
	str     r4, [sp, #-4]!    @ push r4
	str     r5, [sp, #-4]!    @ push r5
	str     r6, [sp, #-4]!    @ push r6
	str     r7, [sp, #-4]!    @ push r7
	str     r8, [sp, #-4]!    @ push r8
	str     r9, [sp, #-4]!    @ push r9
	str     r10, [sp, #-4]!   @ push r10
	str     r12, [sp, #-4]!   @ push r12
	str     r14, [sp, #-4]!   @ push r14
	
	
	
	
	ldr     r0, =GPIO_BASE
	ldr     r1, =GPFSEL_VEC0
	str     r1, [r0, #GPFSEL0 + 0]
	ldr     r1, =GPFSEL_VEC1
	str     r1, [r0, #GPFSEL0 + 4]
	ldr     r1, =GPFSEL_VEC2
	str     r1, [r0, #GPFSEL0 + 8]


		@スイッチを押すとスタート
switch_check:

	mov	r3, #(1 << SWITCH1_PORT)
	ldr 	r2, [r0, #GPLEV0] @GPLEVOのアドレスをr2に代入
	and	r2, r2, r3
	lsr	r2, #13
	cmp	r2, #1
	bne switch_check


	mov r2,#0
	mov r3,#0
	ldr r4, =TIMER_BASE	@ TIMER_BASE 制御用の番地
	ldr r5,[r4,#CLO]	@現在時刻を取得
	ldr r6,=TIMER_HZ	@0.1秒
	add r6,r6,r5		@現在時刻+0.1秒
	ldr r7, =gyou
	mov r8, #0
	mov r9,#0
	mov r10, #0
	ldr r11, =framebuf	@右側のディスプレイの数字のアドレス
	ldr r14,=1000
	add r14,r14,r5





loop1:@フリーランニングカウンタの下位 32 ビットを読み出す．
	ldr r5,[r4,#CLO]	@現在時刻を取得




	cmp	r9,#1				@switch1が押されていればjump_right_check========================================================変更点(バグを生み出す可能性1より)
	beq 	end_rightnumber_check		@============================================================================================変更点(バグを生み出す可能性1より)

	

		@スイッチを押すとスタート
switch_stop1:

	mov	r1, #(1 << SWITCH1_PORT)
	ldr 	r2, [r0, #GPLEV0] @GPLEVOのアドレスをr2に代入
	tst	r2, r1
	beq 	switch2_restart
	mov 	r9,#1
	
end_rightnumber_check:		@============================================================================================変更点(バグを生み出す可能性1より)
	cmp	r3,#0
	bne	end_rightnumber
	
switch2_restart:	
	mov	r1, #(1 << SWITCH2_PORT)
	ldr 	r2, [r0, #GPLEV0] @GPLEVOのアドレスをr2に代入
	tst	r2,r1
	beq col_pro

	mov 	r9,#0 @----------------------------------------------------------
	mov	r3,#1		@サブルーチン呼び出し確認用（一度でも画面が切り替わっていたらスイッチ1が押され次第right_numberへ飛ぶ）=============================変更点(バグを生み出す可能性2より)
	@列の設定
col_pro:
	mov 	r1, #0
	ldrb	r1, [r12, r10]		@10の位
	ldrb	r2, [r11, r10]		@1の位
	orr     r2,r1,r2            , lsl #4
	mov     r1, #(1 << COL1_PORT)
	
	tst	r2, #0x01	@1かどうか調べたい桁にマスクをかけるための数値(1桁目だから1)
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]

	mov     r1, #(1 << COL2_PORT)
	tst	r2, #0x02 @調べたいのは2ビット目だから2
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]

	mov     r1, #(1 << COL3_PORT)
	tst	r2, #0x04	@調べたいのは3ビット目だから4でマスク
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]

	mov     r1, #(1 << COL4_PORT)
	tst	r2, #0x08	@調べたいのは4ビット目だから8でマスク
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]

	mov     r1, #(1 << COL5_PORT)
	tst	r2, #0x10	@調べたいのは5ビット目だから16（16進で10）
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]

	mov     r1, #(1 << COL6_PORT)
	tst	r2, #0x20
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]

	mov     r1, #(1 << COL7_PORT)
	tst	r2, #0x40
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]	

	mov     r1, #(1 << COL8_PORT)
	tst	r2, #0x80
	strne r1, [r0, #GPSET0]
	streq r1, [r0, #GPCLR0]

	@行　点灯
	ldr r2, [r7, r8]
	mov r1, #1
	mov r1, r1, lsl r2
	str r1, [r0, #GPCLR0]




	
@========================================================================
	@タスクの選択
	cmp	r5,r14	@一つの行を表示する時間制限
	bcc endrow_change	@r5がr14未満だったら(フリーランニングカウンタの数値が1000未満だったら)



@========================================================================
row_change:@0.001秒毎に動作する，ディスプレイの1行分を表示するタスク



	@行消し
	ldr r2, [r7, r8]
	mov r1, #1
	mov r1, r1, lsl r2
	str r1, [r0, #GPSET0]


	ldr r14,=1000		@0.001秒
	add r14, r5, r14	@r5(現在時刻) + 0.001秒
	add r10, r10, #1	@行の移動
	add r8, r8, #4		@ROWPORTの切り替え
	
	cmp r10, #8
	bne endrow_change
	
	mov r10, #0
	mov r8, #0

endrow_change:
	cmp 	r9,#0	@switch1が押されていれば---------------------------
	bne	endnumber_change
	
	cmp r5, r6		@一つの数値を表示する時間制限
	bcs number_change		@r5がr6以上だったら(フリーランニングカウンタの数値が1000000以上だったら)
	b endnumber_change

	@数値の切り替え,1秒毎に動作する，フレームバッファを書きかえて，表示する数を増やすタスク
number_change:
	/*mov	r3,#1		@サブルーチン呼び出し確認用（一度でも画面が切り替わっていたらスイッチ1が押され次第right_numberへ飛ぶ）================変更点(バグを生み出す可能性2)*/
 	add r11, #8		@
	mov r10, #0
	mov r8, #0
	ldr r1,=TIMER_HZ
	add r6,r6,r1		@r6(現在時刻) + 1秒

endnumber_change:
	ldr r1,=endframebuf
	cmp r1,r11		@1
	bne end_syokika
	
syokika:@1の位が9まで行くと10の位の更新と１の位の初期化
	ldr r11, =framebuf	@1

end_syokika:	


end_loop1:
	b	loop1
	
end_rightnumber:	
	ldr     r14, [sp], #4      @ pop r14
	ldr     r12, [sp], #4      @ pop r12
	ldr     r10, [sp], #4      @ pop r10
	ldr     r9, [sp], #4       @ pop r9
	ldr     r8, [sp], #4       @ pop r8
	ldr     r7, [sp], #4       @ pop r7
	ldr     r6, [sp], #4       @ pop r6
	ldr     r5, [sp], #4       @ pop r5
	ldr     r4, [sp], #4       @ pop r4
	ldr     r3, [sp], #4       @ pop r3
	ldr     r2, [sp], #4       @ pop r2
	ldr     r1, [sp], #4       @ pop r1
	ldr 	r0, [sp], #4       @ pop r0

	bx 	r14

	
	.section .data

gyou:	.word ROW1_PORT, ROW2_PORT, ROW3_PORT, ROW4_PORT
	.word ROW5_PORT, ROW6_PORT, ROW7_PORT, ROW8_PORT

framebuf:
num0:	.byte 0x00, 0x7, 0x5, 0x5, 0x5, 0x7, 0x00, 0x00
num1:	.byte 0x00, 0x2, 0x3, 0x2, 0x2, 0x7, 0x00, 0x00
num2:	.byte 0x00, 0x7, 0x4, 0x7, 0x1, 0x7, 0x00, 0x00
num3:	.byte 0x00, 0x7, 0x4, 0x7, 0x4, 0x7, 0x00, 0x00
num4:	.byte 0x00, 0x5, 0x5, 0x7, 0x4, 0x4, 0x00, 0x00 
num5:	.byte 0x00, 0x7, 0x1, 0x7, 0x4, 0x7, 0x00, 0x00
num6:	.byte 0x00, 0x7, 0x1, 0x7, 0x5, 0x7, 0x00, 0x00
num7:	.byte 0x00, 0x7, 0x5, 0x4, 0x4, 0x4, 0x00, 0x00
num8:	.byte 0x00, 0x7, 0x5, 0x7, 0x5, 0x7, 0x00, 0x00
num9:	.byte 0x00, 0x7, 0x5, 0x7, 0x4, 0x7, 0x00, 0x00
endframebuf:
