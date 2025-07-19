[BITS 32]              ; We are in 32-bit mode
[GLOBAL _start]        ; Make _start visible to the linker this why its global


_start:
    cli                 ; pause the interrpts i lowkey dont know 

    ; Setting all segments to 0x10 
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax          
    mov gs, ax
    mov ss, ax


    mov esp, 0x9FB00       ; Setting stack pointer to safe adress because stack grows down so its set at a high adress

    call main             ; main function inside of our c file 


.hang:
    jmp .hang              ; This makes an infite loop