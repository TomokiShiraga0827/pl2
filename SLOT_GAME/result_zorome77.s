.equ    GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
    .equ    GPFSEL0,    0x00       @ GPIOポートの機能を選択する番地のオフセット
    .equ    GPSET0,     0x1C       @ GPIOポートの出力値を1にするための番地のオフセット
    .equ    GPCLR0,     0x28       @ GPIOボートの出力値を0にするための番地のオフセット

    .equ    GPFSEL_VEC0, 0x01201000 @ GPFSEL0 に設定する値 (GPIO #4, #7, #8 を出力用に設定)
    .equ    GPFSEL_VEC1, 0x11249041 @ GPFSEL1 に設定する値 (GPIO #10, #12, #14, #15, #16, #17, #18 #19を出力用に設定)
    .equ    GPFSEL_VEC2, 0x00209249 @ GPFSEL2 に設定する値 (GPIO #20, #21, #22, #23, #24, #25, #27 を出力用に設定)
	
	.equ LED_PORT, 10

	.equ SWITCH1_PORT, 13
	.equ SWITCH2_PORT, 26
	.equ SWITCH3_PORT, 5
	.equ SWITCH4_PORT, 6
	.equ GPLEV0, 0x34
	.equ CTL, 0x00
	.equ PWM_RNG2, 0x20
	.equ PWM_DAT2, 0x24
	.equ PWEN2, 8
	.equ MSEN2, 15
	.equ CM_BASE, 0x3f101000
	.equ PWM_BASE, 0x3f20c000
	.equ CM_PWMCTL, 0xa0
	.equ CM_PWMDIV, 0xa4
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
	.global result_zorome77
result_zorome77:	


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


	@(PWM のクロックソースを設定する)
	ldr     r0, =CM_BASE
	ldr     r1, =0x5a000021    
                 @  src = osc, enable=false
	str     r1, [r0, #CM_PWMCTL]

1:    @ wait for busy bit to be cleared
    ldr     r1, [r0, #CM_PWMCTL]
    tst     r1, #0x80
    bne     1b

    ldr     r1, =(0x5a000000 | (2 << 12))  @ div = 2.0
    str     r1, [r0, #CM_PWMDIV]
    ldr     r1, =0x5a000211	@ src = osc, enable=true
    str     r1, [r0, #CM_PWMCTL]

	@(PWM の動作モードを設定する)
	ldr    r0, =PWM_BASE
	ldr r1, =(1 << PWEN2)
	ldr r2, =(1 << MSEN2)
	add r1, r1, r2
	str r1, [r0, #CTL]

	ldr     r0, =GPIO_BASE

	mov r2,#0
	mov r3,#0
	ldr r4, =TIMER_BASE	@ TIMER_BASE 制御用の番地
	ldr r5,[r4,#CLO]	@現在時刻を取得
	ldr r6,=kiseki_wait_time	@fanfare_kaiで記述されている一音の長さのデータです。
	add r6,r6,r5		@現在時刻＋wait_timeで呼び出しのタイミングを生成
	ldr r7, =gyou		@ROW_PORTのデータ
	mov r8, #0		@ROW_PORTの見ている番地をずらすレジスタ
	mov r9,#0	@音のデータをずらしていくレジスタ
	mov r10, #0	@フレームバッファの見ている番地をずらすレジスタ
	ldr r14,=1000	@0.001秒
	add r14,r14,r5	@1行分表示の変更タイミングの生成
	
loop1:@フリーランニングカウンタの下位 32 ビットを読み出す．
	ldr r5,[r4,#CLO]	@現在時刻を取得
	
	@列の設定
	
col_pro:
	mov 	r1, #0
	ldrb	r1, [r12, r10]		@10の位（スイッチで止めた時点でのフレームバッファのアドレス）
	ldrb	r2, [r11, r10]		@1の位（スイッチで止めた時点でのフレームバッファのアドレス）
	orr     r2,r1,r2, lsl #4	@並べて表示するために論理和の計算
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
	cmp	r5,r6	@現在時刻と比べてkiseki_kaiの呼び出しのタイミングが来ていなければ呼び出さない
	bcc	end_sound
	str     r14, [sp, #-4]!   @ push r14	念のため
	bl      kiseki_kai
	ldr     r14, [sp], #4      @ pop r14　　念のため
@=================================呼び出しした場合のみ動作=======================================
	add	r9,r9,#4	@音のデータをずらす
	cmp	r9, #252
	beq	endresult_kiseki	
	ldr     r1,=kiseki_wait_time
	ldr	r6, [r1, r9]		@呼び出しタイミングの更新（一音の長さをそれぞれの音に対して配列として格納している場合は読んでこなければいけない）
	add     r6,r6,r5

	
end_sound:
	
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

endrow_change: b	loop1
	
endresult_kiseki:

	@行消し
	ldr r2, [r7, r8]
	mov r1, #1
	mov r1, r1, lsl r2
	str r1, [r0, #GPSET0]

	@(PWM の動作モードを設定する)
	ldr    r0, =PWM_BASE	@r0にはPWMのベースを設定している
	@音を切る処理
	mov r1,#0
	str    r1, [r0, #PWM_DAT2]


	
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
