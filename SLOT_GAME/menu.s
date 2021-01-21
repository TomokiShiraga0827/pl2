.equ    GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
	.equ    GPFSEL0,    0x00       @ GPIOポートの機能を選択する番地のオフセット
	.equ    GPSET0,     0x1C       @ GPIOポートの出力値を1にするための番地のオフセット
	.equ    GPCLR0,     0x28       @ GPIOボートの出力値を0にするための番地のオフセット

	.equ    GPFSEL_VEC0, 0x01201000 @ GPFSEL0 に設定する値 (GPIO #4, #7, #8 を出力用に設定)
	.equ    GPFSEL_VEC1, 0x01249041 @ GPFSEL1 に設定する値 (GPIO #10, #12, #14, #15, #16, #17, #18 を出力用に設定)
	.equ    GPFSEL_VEC2, 0x00209249 @ GPFSEL2 に設定する値 (GPIO #20, #21, #22, #23, #24, #25, #27 を出力用に設定)

	.equ TIMER_BASE, 0x3f003000
	.equ CLO, 0x4		@フリーランニングカウンタの下位32ビット
	.equ TIMER_HZ, 1000 * 1000	@1秒

	.equ SWITCH1_PORT, 13
	.equ LED_PORT, 10
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

    .section .text
    .global menu
menu:
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
	str     r11, [sp, #-4]!   @ push r11
	str     r12, [sp, #-4]!   @ push r12
	str     r14, [sp, #-4]!   @ push r14











	
	ldr     r0, =GPIO_BASE
	ldr     r1, =GPFSEL_VEC0
	str     r1, [r0, #GPFSEL0 + 0]
	ldr     r1, =GPFSEL_VEC1
	str     r1, [r0, #GPFSEL0 + 4]
	ldr     r1, =GPFSEL_VEC2
	str     r1, [r0, #GPFSEL0 + 8]


	ldr r14, =TIMER_HZ	@1000*1000
	ldr r12, =TIMER_BASE	@ TIMER_BASE 制御用の番地
	mov r11, #0	@初期化の判断用
	mov r10, #0	@r9を変化
	ldr r9, =menuframebuf
	mov r8, #0	@r7を変化
	ldr r7, =gyou
	ldr	r4,[r12,#CLO]	@現在時刻を読み出し
	ldr r5, =1000		@0.001秒
	add r5,r5,r4		@現在時刻＋0.001秒
	add r14,r14,r4		@現在時刻+1秒


loop1:

		@スイッチを押すとスタート
switch_check:
	mov     r1, #(1 << LED_PORT)
	str     r1, [r0, #GPCLR0]

	mov	r3, #(1 << SWITCH1_PORT)
	ldr 	r2, [r0, #GPLEV0] @GPLEVOのアドレスをr2に代入
	and	r2, r2, r3
	lsr	r2, #13
	cmp	r2, #1
	beq 	end_menu
	
	 @フリーランニングカウンタの下位 32 ビットを読み出す．
	ldr	r4,[r12,#CLO]

	@列の設定（指定された行のそれぞれの列の設定）
	ldrb	r2, [r9, r10]
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
	
	@行
	ldr r3, [r7, r8]
	mov r1, #1
	mov r1, r1, lsl r3
	str r1, [r0, #GPCLR0]

	@タスク選択
	cmp r4,r5		@一つの行を表示する時間制限
	bcc endgyouhenkan		@r4がr5未満だったら(フリーランニングカウンタの数値が1000未満だったら)
	
gyouhenkan:@0.001秒毎に動作する，ディスプレイの1行分を表示するタスク
@1行分消灯
	ldr r3, [r7, r8]
	mov r1, #1
	mov r1, r1, lsl r3
	str r1, [r0, #GPSET0]
	
	ldr r6,=1000		@0.001秒
	add r5, r5, r6		@r5(現在時刻) + 0.001秒
	add r10, r10, #1	@行の移動
	add r8, r8, #4		@ROW_PORTの切り替え用
	cmp r10, #8		@8行分表示できた（一つの数値を表現できた)
	bne endgyouhenkan
	
	mov r10, #0
	mov r8, #0
	
endgyouhenkan:	
	cmp r4, r14		@一つの数値を表示する時間制限
	bcs ataichange		@r4がr13以上だったら(フリーランニングカウンタの数値が1000000以上だったら)
	b endataichange
	
	@数値の切り替え,1秒毎に動作する，フレームバッファを書きかえて，表示する数を増やすタスク
ataichange:
	add r9, #8
	mov r6, #0
	mov r10, #0
	mov r8, #0
	ldr r6,=TIMER_HZ	@1秒
	add r14, r14, r6	@r13(現在時刻) + 1秒
	add r11, #1
		
endataichange:
	cmp r11, #10
	beq syokika
	b else
	
syokika:mov r11, #0
	ldr r9, =menuframebuf
	
else:	b loop1


end_menu:
	ldr     r14, [sp], #4      @ pop r14
	ldr     r12, [sp], #4      @ pop r12
	ldr     r11, [sp], #4      @ pop r11
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
	ldr     r0, [sp], #4       @ pop r0

	bx	r14


loop:	b loop

	
	.section .data

gyou:	.word ROW1_PORT, ROW2_PORT, ROW3_PORT, ROW4_PORT
	.word ROW5_PORT, ROW6_PORT, ROW7_PORT, ROW8_PORT

menuframebuf:
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	.byte 0xef, 0xa4, 0xe6, 0x09, 0x20, 0xeb, 0x28, 0x26
	
