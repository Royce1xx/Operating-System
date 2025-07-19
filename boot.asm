[BITS 16]              ; We're starting in 16-bit real mode (default on x86 boot)
[ORG 0x7C00]           ; BIOS loads boot sector at 0x0000:0x7C00 (segment:offset)

start:
    cli                ; Disable interrupts (we're setting up the CPU)
    xor ax, ax
    mov ds, ax         ; Set DS (data segment) to 0
    mov ss, ax         ; Set SS (stack segment) to 0
    mov es, ax         ; Set ES (extra segment) to 0
    mov sp, 0x7BFF     ; Set stack pointer to top of 16-bit memory (just below bootloader)
    sti                ; Re-enable interrupts (optional but safe after setup)

    ; Enable A20 line so we can access memory beyond 1 MB (needed for protected mode)
    call activate

    ; Print a welcome message using BIOS teletype (int 0x10)
    mov si, Hello      ; SI points to our string
.print_loop:
    mov ah, 0x0E       ; BIOS teletype mode (prints one char)
    lodsb              ; Load byte at [SI] into AL, then SI++
    cmp al, 0
    je .after_print
    int 0x10           ; Print character in AL
    jmp .print_loop
.after_print:

    ; Load 1 sector (our kernel) into memory at segment 0x1000
    mov ax, 0x1000     ; Set ES = 0x1000 (segment)
    mov es, ax
    xor bx, bx         ; Offset = 0 (so kernel loads to 0x1000:0000)

    mov ah, 0x02       ; BIOS read sectors function
    mov al, 0x01       ; Read 1 sector
    mov ch, 0x00       ; Cylinder 0
    mov cl, 0x02       ; Sector 2 (bootloader is sector 1)
    mov dh, 0x00       ; Head 0
    mov dl, 0x00       ; Drive 0 (floppy or first hard disk)
    int 0x13           ; BIOS interrupt to read disk

    jc disk_error      ; Jump to error handler if read failed

    ; If read succeeded, switch to protected mode
    call enable_protected_mode

    ; Far jump to protected mode label using code segment selector (0x08)
    jmp 0x08:protected_entry

; ========== SUBROUTINES BELOW ==========

; Enable A20 line (so we can access RAM past 1MB in protected mode)
activate:
    mov ax, 0x2401     ; Enable A20 BIOS function
    int 0x15
    jc fail            ; If it fails, hang
    ret

; Setup GDT, switch to protected mode, and return to do a far jump
enable_protected_mode:
    cli                        ; Disable interrupts during mode switch
    lgdt [gdt_descriptor]      ; Load Global Descriptor Table into GDTR

    mov eax, cr0
    or eax, 1                  ; Set PE (Protection Enable) bit in CR0
    mov cr0, eax

    jmp $                      ; Short jump to flush CPU prefetch queue
    ret

; ========== 32-BIT PROTECTED MODE CODE ==========

[BITS 32]
protected_entry:
    ; Set all segment registers to the GDT data segment (selector 0x10)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup stack pointer to safe memory location
    mov esp, 0x9FB00           ; Stack grows downward, so set to high address

    ; Call the kernel's entry point (loaded at 0x1000:0000)
    call 0x1000:0

.hang32:
    jmp .hang32                ; Infinite loop if kernel returns (shouldn't)

; ========== GDT ==========

[BITS 16]                      ; Back to 16-bit for defining GDT data

gdt_start:
    dq 0x0000000000000000      ; Null descriptor (GDT entry 0, must be all zeroes)
    dq 0x00CF9A000000FFFF      ; Code segment: base=0, limit=4GB, readable/exec
    dq 0x00CF92000000FFFF      ; Data segment: base=0, limit=4GB, read/write
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; GDT size (limit)
    dd gdt_start               ; GDT base address

; ========== ERROR HANDLERS ==========

disk_error:
    cli
.disk_hang:
    hlt
    jmp .disk_hang             ; Freeze CPU if disk read failed

fail:
    cli
.fail_hang:
    hlt
    jmp .fail_hang             ; Freeze CPU if A20 or protected mode setup failed

; ========== BOOT MESSAGE ==========

Hello: db "Royce's 2nd Bootloader", 0

; ========== BOOT SIGNATURE ==========

times 510 - ($ - $$) db 0       ; Pad to 510 bytes
dw 0xAA55                       ; Boot signature (must be last 2 bytes)
