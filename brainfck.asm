; Brainfuck interpreter
; Author: Dominik G.
; Version: 1.1

section .data
    TOKEN_GTS equ 0x3e
    TOKEN_LTS equ 0x3c
    TOKEN_PLU equ 0x2b
    TOKEN_DSH equ 0x2d
    TOKEN_DOT equ 0x2e
    TOKEN_COM equ 0x2c
    TOKEN_LSB equ 0x5b
    TOKEN_RSB equ 0x5d
    TOKEN_TLD equ 0x7e
    TOKEN_NUL equ 0x00
    program times 4096 db 0
    memory times 30000 db 0
    prg_counter dd 0
    mem_counter dd 0

section .text
    global _start

; start the main routine by loading
; the program into memory
_start:
    jmp load_prog

; exit from the main routine with the code 0
exit:
    mov ebx, 0
    mov eax, 1
    int 0x80

; start the loop iter, skip if the value
; at the current memory cell equals 0
bf_loop:
    mov edx, dword [mem_counter]
    lea esi, [memory + edx]
    cmp byte [esi], 0
    je forward
    push dword [prg_counter]
    call inst_seq
    jmp bf_loop

; prepare the stack, save the current sp
; and go to the next instruction
inst_seq:
    push ebp
    mov ebp, esp
    jmp next_instr

; restore the program counter
; return to the procedure caller
iter_term:
    mov edx, [ebp + 8]
    mov dword [prg_counter], edx
    jmp ret_to_caller

; move the program pointer directly
; behind the current loop
forward:
    call jump_over
    jmp next_instr

; prepare the stack, save the current sp
jump_over:
    push ebp
    mov ebp, esp

; skip the current instruction
; or nested branch
skip_inst:
    mov edx, dword [prg_counter]
    lea esi, [program + edx]
    inc dword [prg_counter]
    cmp byte [esi], TOKEN_LSB
    je skip_next
    cmp byte [esi], TOKEN_RSB
    jne skip_inst

; return from the subroutine
ret_to_caller:
    mov esp, ebp
    pop ebp
    ret

; skip the nested loop and move to 
; the next instruction to omit
skip_next:
    call jump_over
    jmp skip_inst

; load the program into memory
load_prog:
    mov edx, dword [prg_counter]
    lea esi, [program + edx]
    push esi
    call read_symbol
    cmp byte [esi], TOKEN_NUL
    je run_prog
    cmp byte [esi], TOKEN_TLD
    je run_prog
    inc dword [prg_counter]
    jmp load_prog

; zero the program pointer and switch
; to the first instruction
run_prog:
    mov dword [prg_counter], 0
    jmp next_instr

; run the instruction based
; on the current token
next_instr:
    mov edx, dword [prg_counter]
    lea esi, [program + edx]
    inc dword [prg_counter]
    cmp byte [esi], TOKEN_GTS
    je inc_ptr
    cmp byte [esi], TOKEN_LTS
    je dec_ptr
    cmp byte [esi], TOKEN_PLU
    je inc_val
    cmp byte [esi], TOKEN_DSH
    je dec_val
    cmp byte [esi], TOKEN_DOT
    je disp_char
    cmp byte [esi], TOKEN_COM
    je get_char
    cmp byte [esi], TOKEN_LSB
    je bf_loop
    cmp byte [esi], TOKEN_RSB
    je iter_term
    cmp byte [esi], TOKEN_NUL
    je exit
    jmp next_instr

; increase the program memory pointer
inc_ptr:
    inc dword [mem_counter]
    jmp next_instr

; decrease the program memory pointer
dec_ptr:
    dec dword [mem_counter]
    jmp next_instr

; increase the value at the current address
inc_val:
    mov edx, dword [mem_counter]
    lea esi, [memory + edx]
    inc byte [esi]
    jmp next_instr

; decrease the value at the current address
dec_val:
    mov edx, dword [mem_counter]
    lea esi, [memory + edx]
    dec byte [esi]
    jmp next_instr

; display the ascii character stored
; at the current memory address
disp_char:
    mov edx, dword [mem_counter]
    lea esi, [memory + edx]
    push esi
    call put_char
    jmp next_instr

; load the character into the current
; memory location from stdin
get_char:
    mov edx, dword [mem_counter]
    lea esi, [memory + edx]
    push esi
    call read_symbol
    jmp next_instr

; read a single token from stdin
; syscall sys_read
read_symbol:
    push ebp
    mov ebp, esp
    mov edx, 1
    mov ecx, [ebp + 8]
    mov ebx, 0
    mov eax, 3
    int 0x80
    mov esp, ebp
    pop ebp
    ret

; use stdout to display a single char
; syscall sys_write
put_char:
    push ebp
    mov ebp, esp
    mov edx, 1
    mov ecx, [ebp + 8]
    mov ebx, 1
    mov eax, 4
    int 0x80
    mov esp, ebp
    pop ebp
    ret