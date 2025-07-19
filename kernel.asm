[BITS 16]
[ORG 0x1000]
global _start
extern main

_start:
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:init_pm

[BITS 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x90000

    call main

.hang:
    hlt
    jmp .hang

; ===== GDT =====
gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF ; Code segment
    dq 0x00CF92000000FFFF ; Data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10
