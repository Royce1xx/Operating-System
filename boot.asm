bits 16
org 0x7c00

; Setup segments and stack 
cli
xor ax, ax
mov ds, ax
mov ss, ax
mov es, ax
mov sp, 0x7BFF
sti

; Calls the Enable_20 function
call activate 

; print boot message
mov si, Hello

; prints hello to the screen
print:
    mov ah, 0x0e
    mov al, [si] 
    int 0x10
    add si, 1
    cmp byte [si], 0
    jne print

; Added label to continue after print loop
after_print:

; load kernel to 0x1000:0000
mov ax, 0x1000
mov es, ax
xor bx, bx

mov ah, 0x02       ;Bios read sector to read in the kernel
mov al, 0x01       ; read 1 sector
mov ch, 0x00       ; cylinder
mov cl, 0x02       ; sector (start at sector 2)
mov dh, 0x00       ; head
mov dl, 0x00       ; drive
int 0x13           ; This reads the data from the disk

jc disk_error      ; if error, jump to disk_error
jmp 0x1000:0000    ; This jumps to the kernel (loaded at 0x1000:0000)

; This enables the A_20 so we can get into protected mode
activate:
    mov ax, 0x2401
    int 0x15
    jc fail
    ret

; if it fails this turns off interrupts
fail:
    cli

; this stalls our cpu if things go wrong
hang:
    hlt
    jmp hang

; handles disk read errors
disk_error:
    cli         ; Stop the interrupts
disk_hang:
    hlt             ;Stops the cpu 
    jmp disk_hang

; welcome to the bootloader
Hello:
    db "Royce's 2nd Bootloader", 0

; Makes sure the boot sector is 512 bytes and ends in 0xAA55
times 510 - ($ - $$) db 0
dw 0xAA55
