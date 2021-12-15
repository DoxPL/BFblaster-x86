; Brainfuck interpreter
; Author: Dominik G.

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
    TOKEN_NUL equ 0x0
    memory times 30000 db 0
    program times 4096 db 0
    mem_ptr dd 0
    prog_ptr dd 0

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
    mov edx, dword [prog_ptr]
    lea esi, [program + edx]
    push esi
    call read_symbol
    cmp byte [esi], TOKEN_NUL
    je run_prog
    cmp byte [esi], TOKEN_TLD
    je run_prog
    inc dword [prog_ptr]
    jmp load_prog

run_prog:
    mov dword [prog_ptr], 0
    jmp next_instr

next_instr:
    mov edx, dword [prog_ptr]
    lea esi, [program + edx]
    inc dword [prog_ptr]
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
    je _loop
    cmp byte [esi], TOKEN_RSB
    je rewind
    cmp byte [esi], TOKEN_NUL
    je _success
    jmp next_instr

_loop:
    mov edx, dword [mem_ptr]
    lea esi, [memory + edx]
    cmp byte [esi], 0
    je forward
    jmp next_instr

forward:
    mov edx, dword [prog_ptr]
    lea esi, [program + edx]
    inc dword [prog_ptr]
    cmp byte [esi], 0x5d
    je next_instr
    jmp forward

rewind:
    dec dword [prog_ptr]
    mov edx, dword [prog_ptr]
    lea esi, [program + edx]
    cmp byte [esi], 0x5b
    je _loop
    jmp rewind

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
    push esi
    call read_symbol
    jmp next_instr

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