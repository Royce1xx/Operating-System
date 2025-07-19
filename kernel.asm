[BITS 32]
[GLOBAL _start]
extern main          ; We will call this in kernel.c

_start:
    cli

    ; Setup segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup stack
    mov esp, 0x9FB00

    ; Optional: Show debug text
    mov edi, 0xB8000
    mov esi, message
    call print_string

    ; Call the C kernel entry point
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
