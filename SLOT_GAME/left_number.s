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

    .section .init
    .global _start
_start:

	mov sp, #STACK
	
	ldr     r0, =GPIO_BASE
	ldr     r1, =GPFSEL_VEC0
	str     r1, [r0, #GPFSEL0 + 0]
	ldr     r1, =GPFSEL_VEC1
	str     r1, [r0, #GPFSEL0 + 4]
	ldr     r1, =GPFSEL_VEC2
	str     r1, [r0, #GPFSEL0 + 8]


@menuのサブルーチンの呼び出し-------------------------------------------------------------------------------------------
top:
	bl	menu
@menuの中ではすべてのレジスタがプッシュポップされている----------------------------------------------------------------------
	
@スイッチが押されるとleft_numberに返ってくる------------------------------------------------------------------------------



@ゲーム動作中はLEDがつく	
	mov     r1, #(1 << LED_PORT)
	str     r1, [r0, #GPSET0]
@初期設定（menuのサブルーチンへとんだ後は必ず初期化される）------------------------------------------------------------------------------------
	mov r2,#0
	mov r3,#0
	ldr r4, =TIMER_BASE	@ TIMER_BASE 制御用の番地
	ldr r5,[r4,#CLO]	@現在時刻を取得
	ldr r6,=TIMER_HZ	@0.1秒
	add r6,r6,r5		@現在時刻+0.1秒
	ldr r7, =gyou		@ROW-PORT用bufferの代入
	mov r8, #0		@ROW-PORT用bufferのアドレス位置をずらす用途
	mov r9,#0		@このレジスタに0以外が入っているとスイッチ1が押されたことを示す/0だとスイッチ1が押されていない
	mov r10, #0		@画面に表示するためのデータが入っているframebufのアドレス位置をずらす用途
	mov r11, #0		@スイッチ1が押されており（r9=1）,このレジスタに0以外が入っているとright_numberへ
	ldr r12,=framebuf	@画面に表示するデータが入ったframebuf
	ldr r14,=1000		@0.001秒
	add r14,r14,r5		@行切り替えのための制限時間（現在時間　+　0.001）
@初期設定終了----------------------------------------------------------------------------------------------------------




loop1:@8×8ディスプレイの左側4×4を使い0~9を0.1秒間隔で切り替えて表示する--------------------------------------------------------
	
	@フリーランニングカウンタの下位 32 ビットを読み出す．
	ldr r5,[r4,#CLO]	@現在時刻を取得
	
@スイッチ3を押すとリセット.topに飛び、再びmenuのサブルーチンへ------------------------------------------------------------------
switch_reset:
	mov	r3, #(1 << SWITCH3_PORT)	@switch3の状態を確認
	ldr 	r2, [r0, #GPLEV0] 		@GPLEVOのアドレスをr2に代入
	tst	r2, r3				@switch3のアドレスに入っている値が0でなければtop(menuのサブルーチンへ)
	bne 	top
@リセットスイッチ３確認終了----------------------------------------------------------------------------------------------


	cmp	r9,#1				@switch1が押されていればjump_right_check========================================================変更点(バグを生み出す可能性1より)
	beq 	jump_right_check		@============================================================================================変更点(バグを生み出す可能性1より)

@
switch_stop1:
	mov	r3, #(1 << SWITCH1_PORT)	@switch1の状態を確認
	ldr 	r2, [r0, #GPLEV0]		@GPLEVOのアドレスをr2に代入
	tst	r2, r3				@switch1のアドレスに入っている値が0ならばswitch2_restart
	beq switch2_restart

	mov 	r9,#1				@switch1が押されるとr9に1を代入


jump_right_check:		@============================================================================================変更点(バグを生み出す可能性1より)
	cmp	r11,#0
	bne	jump_right
	
switch2_restart:	
	mov	r3, #(1 << SWITCH2_PORT)	@switch２の状態を確認
	ldr 	r2, [r0, #GPLEV0] 		@GPLEVOのアドレスをr2に代入
	tst	r2,r3				@switch2のアドレスに入っている値が0ならばcol_pro
	beq 	col_pro
	mov 	r9,#0				@switch2が押されればr9に0を代入
	
	mov	r11,#1		@サブルーチン呼び出し確認用（一度でも画面が切り替わっていたらスイッチ1が押され次第right_numberへ飛ぶ）=============================変更点(バグを生み出す可能性2より)
@-------------------------------------------------------------------------------------------------------------------------




	
@8×8ディスプレイの左側4×4を使い0~9を0.1秒間隔で切り替えて表示する
	
@列の設定（各行に対する）-------------------------------------------------------------------------------------------------------------------
col_pro:
	ldrb	r2, [r12, r10]		@1の位
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

@列の設定終了（各行に対する）---------------------------------------------------------------------------



	
	
@行の設定（光る/光らない）------------------------------------------------------------------------------
	ldr r3, [r7, r8]
	mov r1, #1
	mov r1, r1, lsl r3
	str r1, [r0, #GPCLR0]

@行の設定終了（光る/光らない）------------------------------------------------------------------------------





	

@タスクの選択-------------------------------------------------------------------------------------------
	cmp	r5,r14		@一つの行を表示する時間制限
	bcc endrow_change	@r5がr14未満だったら(フリーランニングカウンタの数値が1000未満だったら)
@タスクの選択終了-------------------------------------------------------------------------------------------





	
@0.001秒毎に動作する，ディスプレイの1行分を表示するタスク---------------------------------------------------------	
row_change:



	
@行消し(行に対して光らせないように出力値を１に設定)---------------------------------------------------------------
	ldr r3, [r7, r8]
	mov r1, #1
	mov r1, r1, lsl r3
	str r1, [r0, #GPSET0]
@行消し終了(行に対して光らせないように出力値を１に設定)------------------------------------------------------------------


	
	ldr r14,=1000		@0.001秒
	add r14, r5, r14	@r5(現在時刻) + 0.001秒
	add r10, r10, #1	@行の移動
	add r8, r8, #4		@ROWPORTの切り替え
	
	cmp r10, #8		@8行めまで表示していなければendrow_chengeへ	
	bne endrow_change
	
	mov r10, #0		@r10 = 0(framebufをずらしていたレジスタを初期化)
	mov r8, #0		@r8 = 0(ROW_PORTをずらしていたレジスタを初期化)

	
endrow_change:
	cmp 	r9,#0		@switch1が押されていれば表示画面を変化させない
	bne	endnumber_change
	
	cmp r5, r6		@一つの数値を表示する時間制限
	bcs number_change	@r5がr6以上だったら(フリーランニングカウンタの数値が1000000以上だったら)
	b endnumber_change


	
@数値の切り替え,1秒毎に動作する，フレームバッファを書きかえて，表示する数を増やすタスク-------------------------------------------
number_change:

 	add 	r12, #8		@表示画面を切り替えるためにframebufの位置を8ずらす
	mov 	r10, #0		@r10を初期化
	mov 	r8, #0		@r8を初期化
	ldr 	r1,=TIMER_HZ	@r1に0.1代入
	add 	r6,r6,r1	@r6(現在時刻) + 0,1秒


	
endnumber_change:
	ldr r3,=endframebuf	@framebufの最後のアドレス位置を代入
	cmp r3,r12		@framebufの最終アドレス位置とr3を比べ等しかったらend_syokika
	bne end_syokika


	
syokika:@9まで行くと初期化
	ldr r12, =framebuf

end_syokika:	


end_loop1:
	b	loop1










	
@スウィッチ1が押される(r9かつr11が1だった場合)right_numberへ----------------------------------------------------------------------------
	
jump_right:
	bl	right_number


@-----------------------------------------------------------------------------------

	
	
	cmp	r12,r11		@adressの比較
	bne	faled		@失敗（ゾロ目じゃない）

success:@ゾロ目であった場合はどの番号であるか比較し番号に合った処理へ------------------------------------------------------------------------
	mov     r1, #(1 << LED_PORT)
	str     r1, [r0, #GPSET0]

	
	ldr	r3,=num0
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num1
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num2
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num3
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num4
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num5
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num6
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num7
	cmp	r12,r3
	beq	zorome77

	ldr	r3,=num8
	cmp	r12,r3
	beq	zorome

	ldr	r3,=num9
	cmp	r12,r3
	beq	zorome


faled:	@ゾロ目ではなかった場合
	bl	result_faled

	mov     r1, #(1 << LED_PORT)
	str     r1, [r0, #GPSET0]


	
switch_reset2:
	mov	r3, #(1 << SWITCH3_PORT)
	ldr 	r2, [r0, #GPLEV0] @GPLEVOのアドレスをr2に代入
	tst	r2, r3
	bne 	top	@switch_check


	
end_faledend:	b	switch_reset2

	
	
zorome:
	
	bl	result_zorome


	
switch_reset3:
	mov	r3, #(1 << SWITCH3_PORT)
	ldr 	r2, [r0, #GPLEV0] @GPLEVOのアドレスをr2に代入
	tst	r2, r3
	bne 	top	@switch_check
	
	b	switch_reset3


	
zorome77:	
	bl	result_zorome77
	
switch_reset4:
	mov	r3, #(1 << SWITCH3_PORT)
	ldr 	r2, [r0, #GPLEV0] @GPLEVOのアドレスをr2に代入
	tst	r2, r3
	bne 	top	@switch_check
	
	b	switch_reset4

	
loop:	b loop
