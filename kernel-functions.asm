; Copyright 2018-2019 Brian Otto @ https://hackerpulp.com
; 
; Permission to use, copy, modify, and/or distribute this software for any 
; purpose with or without fee is hereby granted, provided that the above 
; copyright notice and this permission notice appear in all copies.
; 
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH 
; REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY 
; AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, 
; INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM 
; LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE 
; OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR 
; PERFORMANCE OF THIS SOFTWARE.

; we use the same calling conventions as UEFI
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G6.1000069

funIntegerToAscii:
    ; save rbx and rsi so that we can restore them later
    push rbx
    push rsi
    
    ; set rax to the passed in integer
    mov rax, rcx
    
    ; set our counter to 0
    mov rbx, 0
    
    ; there is no return and so we continue

funIntegerToAsciiDivide:
    ; increment our counter by 1
    inc rbx
    
    ; reset our ascii character
    mov rdx, 0
    
    ; divide rax by 10
    ; rsi works on rax
    ; e.g. 123 / 10 = 12.3
    mov rsi, 10
    idiv rsi
    
    ; the remainder is stored in rdx
    ; add 48 to get it's ASCII value
    ; 3 + 48 = 51 (the character '3')
    add rdx, 48
    
    ; save the ASCII value to the stack
    push rdx
    
    ; can rax be divided again
    ; rax = 12, yes it can
    cmp rax, 0
    jnz funIntegerToAsciiDivide
    
    ; there is no return and so we continue

funIntegerToAsciiOutput:
    ; increment our counter by 1
    dec rbx
    
    ; set the 1st argument to the top of the stack
    ; 1 <- we are here
    ; 2
    ; 3
    mov rcx, rsp
    
    ; write the ASCII character there and then remove it
    call efiOutputString
    pop rax
    
    ; have we written all the characters
    cmp rbx, 0
    jnz funIntegerToAsciiOutput
    
    ; restore rbx and rsi
    pop rsi
    pop rbx
    
    ret

funLoopForever:
    jmp funLoopForever
