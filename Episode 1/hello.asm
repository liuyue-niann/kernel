org 07c00h
mov ax,cs
mov ds,ax
mov es,ax
call Disp
jmp $
Disp:
    mov ax,BootMsg
    mov bp,ax
    mov cx,16
    mov ax,01301h
    mov bx,000ch
    mov dx,0
    int 10h
BootMsg: db "Hello World!"
times 510 - ($-$$) db 0
dw 0xaa55