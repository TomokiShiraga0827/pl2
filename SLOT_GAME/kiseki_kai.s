.equ    GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
	.equ 	TIMER_BASE, 0x3f003000
	.equ 	CLO, 0x4	
	.equ    GPFSEL19,    0x04       @ GPIOポートの機能を選択する番地のオフセット
	.equ    GPFSEL_VEC1, 0x10000000 @ GPFSEL1 に設定する値 (GPIO #19 を出力用に設定)
	

	.equ    PWM_HZ, 9600 * 1000

	.equ    KEY_re, PWM_HZ / 294     @ レ　294Hz のときの1周期のクロック数
	.equ    KEY_mi, PWM_HZ / 330     @ ミ　330Hz のときの1周期のクロック数
	.equ    KEY_fa, PWM_HZ / 349     @ ファ　262Hz のときの1周期のクロック数
	.equ    KEY_so, PWM_HZ / 392     @ ソ　392Hz のときの1周期のクロック数
	.equ    KEY_ra, PWM_HZ / 440     @ 440Hz のときの1周期のクロック数
	.equ    KEY_si, PWM_HZ / 494     @ 494Hz のときの1周期のクロック数
	.equ    KEY_do, PWM_HZ / 523     @ 523Hz のときの1周期のクロック数
	.equ    KEY_le, PWM_HZ / 587     @ 587Hz のときの1周期のクロック数
	.equ    KEY_le1, PWM_HZ / 622     @ 622Hz のときの1周期のクロック数

	@(その他必要な定数を定義する)
	.equ 	PWM_BASE, 0x3f20c000
	.equ 	CTL, 0x00
	.equ 	PWM_RNG2, 0x20
	.equ 	PWM_DAT2, 0x24
	.equ 	WAIT_TIME1, 1000*300
	.equ 	WAIT_TIME2, 1000*600
	.equ 	WAIT_TIME3, 1000*100

    .section .text
    .global kiseki_kai, kiseki_wait_time
kiseki_kai:

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
	ldr    r0, =PWM_BASE
	ldr    r6, =sabi1
	
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
	
loop:	b    loop

	.section .data
sabi1:	.word KEY_si, KEY_le, KEY_le, KEY_le, KEY_si, KEY_le, KEY_le, KEY_do
sabi2:	.word KEY_si, KEY_ra, KEY_ra, KEY_so, KEY_ra, KEY_si, KEY_si, KEY_si
sabi3:	.word KEY_si, KEY_si, KEY_do, KEY_si, KEY_ra, KEY_so, KEY_so, KEY_re 
sabi4:	.word KEY_re, KEY_si, KEY_do, KEY_si, KEY_ra, KEY_si, KEY_ra, KEY_ra
sabi5:	.word KEY_si, KEY_le, KEY_le, KEY_le, KEY_si, KEY_le, KEY_le1
sabi6:	.word KEY_si, KEY_ra, KEY_si, KEY_ra, KEY_so, KEY_ra, KEY_si, KEY_si
sabi7:	.word KEY_si, KEY_si, KEY_si, KEY_do, KEY_si, KEY_ra, KEY_so, KEY_ra
sabi8:	.word KEY_ra, KEY_ra, KEY_so, KEY_so, KEY_so, KEY_so, KEY_so, KEY_so
kiseki_wait_time: .word WAIT_TIME1, WAIT_TIME1, WAIT_TIME2, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME3, WAIT_TIME1, WAIT_TIME1, WAIT_TIME2, WAIT_TIME3, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME2, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME2, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1,WAIT_TIME1, WAIT_TIME2, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME1, WAIT_TIME2, WAIT_TIME1, WAIT_TIME1 
kiseki_endwait_time:
	
