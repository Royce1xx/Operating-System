[org 0x7c00]
[BITS 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Load second stage (kernel loader)
    mov si, msg
    call print

    mov ah, 0x02
    mov al, 16         ; 16 sectors (8KB)
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x00       ; Boot drive

    mov bx, 0x1000
    int 0x13
    jc disk_error

    jmp 0x0000:0x1000

disk_error:
    mov si, err
    call print
    jmp $

print:
    mov ah, 0x0E
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

msg db "Loading RoyceOS Kernel...", 0
err db "Disk Error", 0

times 510-($-$$) db 0
dw 0xAA55
