; Brainfuck interpreter
; Author: Dominik G.

section .data
    memory times 30000 db 0
    mem_ptr dw 0
    program times 4096 db 0
    prog_ptr dw 0

section .bss
    symbol resb 1

section .text
    global _start

_start:
    jmp load_prog

_success:
    mov ebx, 0
    jmp _exit

_failure:
    mov ebx, 1
    jmp _exit

_exit:
    mov eax, 1
    int 0x80

load_prog:
    call read_symbol
    mov edx, dword [prog_ptr]
    lea esi, [program + edx]
    cmp byte [esi], 0x0
    je run_prog
    inc dword [prog_ptr] 
    jmp load_prog

run_prog:
    mov byte [prog_ptr], 0
    jmp run_instr

run_instr:
    mov edx, dword [prog_ptr]
    lea esi, [program + edx]
    ; token == '>'
    cmp byte [esi], 0x3e
    je inc_ptr
    ; token == '<'
    cmp byte [esi], 0x3c
    je dec_ptr
    ; token == '+'
    cmp byte [esi], 0x2b
    je inc_val
    ; token == '-'
    cmp byte [esi], 0x2d
    je dec_val
    ; token == '.'
    cmp byte [esi], 0x2e
    je disp_char
    ; token == ','
    cmp byte [esi], 0x2c
    je get_char
    ; token == '['
    cmp byte [esi], 0x5b
    je loop
    ; token == ']'
    cmp byte [esi], 0x5d
    ; token == '0'
    cmp byte [esi], 0x0
    je _success
    jmp _failure

next_instr:
    inc dword [prog_ptr]
    jmp run_instr

loop:
    ; mov edx, dword [mem_ptr]
    ; cmp [memory + edx], 0
    ; je run_instr
    ; cmp [program + prog_ptr], 0
    je next_instr

inc_ptr:
    inc dword [mem_ptr]
    jmp next_instr

dec_ptr:
    dec dword [mem_ptr]
    jmp next_instr

inc_val:
    mov edx, dword [mem_ptr]
    lea esi, [memory + edx]
    inc byte [esi]
    jmp next_instr

dec_val:
    mov edx, dword [mem_ptr]
    lea esi, [memory + edx]
    dec byte [esi]
    jmp next_instr

disp_char:
    mov edx, dword [mem_ptr]
    lea esi, [memory + edx]
    push esi
    call put_char
    jmp next_instr

get_char:
    mov edx, dword [mem_ptr]
    lea esi, [memory + edx]
    mov edx, 1
    mov ecx, esi
    mov ebx, 0
    mov eax, 3
    int 0x80
    jmp next_instr

read_symbol:
    push ebp
    mov ebp, esp
    mov edx, dword [prog_ptr]
    lea esi, [program + edx]
    mov byte [esi], 0
    mov edx, 1
    mov ecx, [esi]
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


;;;
test:
    mov byte [memory], 98
    jmp disp_char