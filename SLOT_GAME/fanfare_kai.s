.equ    GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
	.equ TIMER_BASE, 0x3f003000
	.equ CLO, 0x4	
	.equ    GPFSEL19,    0x04       @ GPIOポートの機能を選択する番地のオフセット
	.equ    GPFSEL_VEC1, 0x10000000 @ GPFSEL1 に設定する値 (GPIO #19 を出力用に設定)
	

	.equ    PWM_HZ, 9600 * 1000

	.equ    KEY_E6, PWM_HZ / 1319  @ 440Hz のときの1周期のクロック数(低いミ)
	.equ    KEY_F6, PWM_HZ / 1397  	@ 494Hz のときの1周期のクロック数(低いファ)
	.equ    KEY_G6, PWM_HZ / 1568   @ 523Hz のときの1周期のクロック数(低いソ)
	.equ    KEY_A6, PWM_HZ / 1760   @ 587Hz のときの1周期のクロック数(低いラ)
	.equ    KEY_C7, PWM_HZ / 2093  @ 659Hz のときの1周期のクロック数(真ん中ド)
	.equ    KEY_E7, PWM_HZ / 2637  @ 698Hz のときの1周期のクロック数(真ん中ミ)
	.equ    KEY_G7, PWM_HZ / 3136  @ 784Hz のときの1周期のクロック数(真ん中ソ)
	.equ    KEY_Gs7, PWM_HZ / 3322 @ 784Hz のときの1周期のクロック数(真ん中ソ#)
	.equ    KEY_As7, PWM_HZ / 3729 @ 880Hz のときの1周期のクロック数(真ん中ラ#)
	.equ    KEY_C8, PWM_HZ / 4186  @ 880Hz のときの1周期のクロック数(高いド)
	.equ	KEY_D8, PWM_HZ/ 4698

	@(その他必要な定数を定義する)
	.equ PWM_BASE, 0x3f20c000
	.equ CTL, 0x00
	.equ PWM_RNG2, 0x20
	.equ PWM_DAT2, 0x24
	.equ	WAIT_TIME1, 1000*500	@ 0.5秒
	.equ	WAIT_TIME2, 1000*250	@ 0.25秒
	.equ	WAIT_TIME_2, 100*700   @0.65
	.equ	WAIT_TIME3, 1000*750	@ 0.75秒
	.equ	WAIT_TIME4, 1000*1750	@ 1.75秒
	
    .section .text
    .global fanfare_kai,fanfare_wait_time
fanfare_kai:

	str     r0, [sp, #-4]!    @ push r0
	str     r1, [sp, #-4]!    @ push r1
	str     r2, [sp, #-4]!    @ push r2
	str     r3, [sp, #-4]!    @ push r3
	str     r4, [sp, #-4]!    @ push r4
	str     r5, [sp, #-4]!    @ push r5
	str     r6, [sp, #-4]!    @ push r6
	str     r7, [sp, #-4]!    @ push r7
	str     r8, [sp, #-4]!    @ push r8
	@str     r9, [sp, #-4]!    @ push r9
	str     r10, [sp, #-4]!   @ push r10
	str     r11, [sp, #-4]!   @ push r11
	str     r12, [sp, #-4]!   @ push r12
	str     r14, [sp, #-4]!   @ push r14

	@フリーランニングカウンタの下位 32 ビットを読み出す．
	ldr    	r0, =PWM_BASE
	ldr 	r6, =music0
	
	@ 音を鳴らす
	ldr    r1,[r6,r9]
	str    r1, [r0, #PWM_RNG2]
	lsr    r1, r1, #1
	str    r1, [r0, #PWM_DAT2]

	
	
@end:	mov r1,#0
@	str    r1, [r0, #PWM_DAT2]
	ldr     r14, [sp], #4      @ pop r14
	ldr     r12, [sp], #4      @ pop r12
	ldr     r11, [sp], #4      @ pop r11
	ldr     r10, [sp], #4      @ pop r10
	@ldr     r9, [sp], #4       @ pop r9
	ldr     r8, [sp], #4       @ pop r8
	ldr     r7, [sp], #4       @ pop r7
	ldr     r6, [sp], #4       @ pop r6
	ldr     r5, [sp], #4       @ pop r5
	ldr     r4, [sp], #4       @ pop r4
	ldr     r3, [sp], #4       @ pop r3
	ldr     r2, [sp], #4       @ pop r2
	ldr     r1, [sp], #4       @ pop r1
	ldr     r0, [sp], #4       @ pop r0
	bx      r14              @ 呼び出し元に戻る
loop:
	b    loop


	.section .data
	
music0:	 .word KEY_G6, KEY_G6, KEY_G6
music1:	 .word KEY_A6, KEY_A6, KEY_A6, KEY_G6, KEY_G6, KEY_G6, KEY_F6, KEY_F6, KEY_F6
music2:	 .word KEY_G6, KEY_E6, KEY_G6, KEY_C7, KEY_G6, KEY_C7, KEY_E7, KEY_C7, KEY_E7, KEY_G7, KEY_E7, KEY_G7
music3:	 .word KEY_C8, KEY_C8, KEY_C8, KEY_G7, KEY_G7, KEY_G7, KEY_Gs7, KEY_Gs7 
music4:	 .word KEY_As7
music5:	 .word KEY_C8, KEY_D8
fanfare_wait_time:.word WAIT_TIME1, WAIT_TIME2, WAIT_TIME2,WAIT_TIME2,WAIT_TIME2, WAIT_TIME2, WAIT_TIME2, WAIT_TIME2,WAIT_TIME2, WAIT_TIME2, WAIT_TIME2, WAIT_TIME2,WAIT_TIME2, WAIT_TIME2, WAIT_TIME2, WAIT_TIME2,WAIT_TIME2, WAIT_TIME2, WAIT_TIME2, WAIT_TIME2,WAIT_TIME2, WAIT_TIME2, WAIT_TIME2, WAIT_TIME2,WAIT_TIME2, WAIT_TIME2, WAIT_TIME2, WAIT_TIME2,WAIT_TIME2, WAIT_TIME2, WAIT_TIME2, WAIT_TIME3,WAIT_TIME_2,WAIT_TIME3,WAIT_TIME4
fanfare_endwait_time:	
