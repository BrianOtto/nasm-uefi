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

; generate 64-bit code
bits 64

; use relative addresses
default rel

; contains the code that will run
section .text

; allows the linker to see the entry symbol
global start

%include "kernel-functions.asm"
%include "kernel-efi.asm"
%include "kernel-api.asm"

start:
    ; reserve space for 4 arguments
    sub rsp, 4 * 8
    
    ; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G6.1000024
    ; the "2.3.4.1 Handoff State" section
    
    ; rcx is the 1st argument passed to us by the UEFI firmware
    ; it will contain the EFI_HANDLE
    mov [hndImageHandle], rcx
    
    ; rdx is the 2nd argument passed to us by the UEFI firmware
    ; it points to the EFI_SYSTEM_TABLE
    mov [ptrSystemTable], rdx
    
    ; verify the EFI_TABLE_HEADER.Signature
    call apiVerifySignature
    
    ; output the OS and Firmware versions
    call apiOutputHeader
    
    ; TODO: boot a kernel
    
    ; loop forever so we can see the header before the UEFI application exits
    jmp funLoopForever
    
    add rsp, 4 * 8
    mov eax, EFI_SUCCESS
    ret

error:
    ; all functions are expected to store their error code in rax
    ; and so a "mov eax" is not needed
    add rsp, 4 * 8
    ret
    
    ; TODO: get this to return without hanging

codesize equ $ - $$

; contains nothing - but it is required by UEFI
section .reloc

; contains the data being stored
section .data
    ; UEFI requires we use Unicode strings
    strHeader      db __utf16__ `Hacker Pulp OS v0.1\r\nRunning on \0`
    strHeaderV     db __utf16__ ` v\0`
    
    ; stores the EFI_HANDLE
    hndImageHandle dq 0
    
    ; stores the EFI_SYSTEM_TABLE
    ptrSystemTable dq 0
    
datasize equ $ - $$