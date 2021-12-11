; Brainfuck interpreter
; Author: Dominik G.

section .data
    SYNTAX_ERR_LB db 'Syntax error'
    prog_buff times 30000 db 0
    prog_ptr dw 0
    symbol_index db 0

section .bss
    symbol resb 1

section .text
    global _start

_start:
    jmp run_instr

_success:
    mov ebx, 0
    jmp _exit

_failure:
    mov ebx, 1
    jmp _exit

_exit:
    mov eax, 1
    int 0x80

run_instr:
    mov byte [symbol], 0x0
    call read_symbol
    ; symbol == '>'
    cmp byte [symbol], 0x3e
    je inc_ptr
    ; symbol == '<'
    cmp byte [symbol], 0x3c
    je dec_ptr
    ; symbol == '+'
    cmp byte [symbol], 0x2b
    je inc_val
    ; symbol == '-'
    cmp byte [symbol], 0x2d
    je dec_val
    ; symbol == '.'
    cmp byte [symbol], 0x2e
    je disp_char
    ; symbol == ','
    cmp byte [symbol], 0x2c
    je get_char
    ; symbol == '['
    cmp byte [symbol], 0x5b
    ; symbol == ']'
    cmp byte [symbol], 0x5d
    ; symbol == '0'
    cmp byte [symbol], 0x0
    je _success
    jmp _failure

inc_ptr:
    inc dword [prog_ptr]
    jmp run_instr

dec_ptr:
    dec dword [prog_ptr]
    jmp run_instr

inc_val:
    mov edx, dword [prog_ptr]
    lea esi, [prog_buff + edx]
    inc byte [esi]
    jmp run_instr

dec_val:
    mov edx, dword [prog_ptr]
    lea esi, [prog_buff + edx]
    dec byte [esi]
    jmp run_instr

disp_char:
    mov edx, dword [prog_ptr]
    lea esi, [prog_buff + edx]
    push esi
    call put_char
    jmp run_instr

get_char:
    call read_symbol
    lea esi, [prog_buff]
    mov dl, [symbol]
    mov byte [esi], dl
    jmp run_instr

read_symbol:
    push ebp
    mov ebp, esp
    mov edx, 1
    mov ecx, symbol
    mov ebx, 0
    mov eax, 3
    int 0x80
    mov esp, ebp
    pop ebp
    ret

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