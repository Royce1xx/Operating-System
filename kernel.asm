[BITS 32]
[GLOBAL _start]
extern main          ; Reference to the C function main

_start:
    cli

    ; Setup segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup stack pointer
    mov esp, 0x9FB00

    ; Print message to screen using BIOS text mode (0xB8000)
    mov edi, 0xB8000
    mov esi, message
    call print_string

    ; Call the C kernel main function
    call main

.hang:
    cli
    hlt
    jmp .hang

print_string:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0F
    stosw
    jmp print_string
.done:
    ret

message: db "Kernel Loaded!", 0
