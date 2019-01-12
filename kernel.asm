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
    ; save the location of UEFI
    mov [ptrUEFI], rsp
    
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
    
    ; locate a graphics device and allocate a frame buffer
    call apiGetFrameBuffer
    
    ; get a memory map and exit UEFI boot services
    call apiExitUEFI
    
    ; load our kernel
    call apiLoadKernel
    
    add rsp, 4 * 8
    mov rax, EFI_SUCCESS
    ret

error:
    ; move to the location of UEFI and return
    mov rsp, [ptrUEFI]
    ret

errorCode:
    ; save our error code
    push rax
    
    ; display the message
    mov rcx, strErrorCode
    call efiOutputString
    
    ; grab our error code and write it
    ; see the UEFI definitions in kernel-efi.asm
    mov rcx, [rsp]
    call funIntegerToAscii
    
    ; restore the error code
    pop rax
    
    jmp error

codesize equ $ - $$

; contains nothing - but it is required by UEFI
section .reloc

; contains the data being stored
section .data
    ; UEFI requires we use Unicode strings
    strHeader               db   __utf16__ `Hacker Pulp OS v0.1\r\nRunning on \0`
    strHeaderV              db   __utf16__ ` v\0`
    strErrorCode            db   __utf16__ `\r\n\nError Code #\0`
    strDebugText            db   __utf16__ `\r\n\nDebug: \0`
    
    ; stores the location of UEFI
    ptrUEFI                 dq   0
    
    ; stores the EFI_HANDLE
    hndImageHandle          dq   0
    
    ; stores the EFI_SYSTEM_TABLE
    ptrSystemTable          dq   0
    
    ; stores the EFI_GRAPHICS_OUTPUT_PROTOCOL
    ptrInterface            dq   0
    
    ; stores the memory map data
    intMemoryMapSize        dq   EFI_MEMORY_DESCRIPTOR_size * 1024
    bufMemoryMap            resb EFI_MEMORY_DESCRIPTOR_size * 1024
    ptrMemoryMapKey         dq   0
    ptrMemoryMapDescSize    dq   0
    ptrMemoryMapDescVersion dq   0
    
    ; stores the frame buffer base
    ptrFrameBuffer          dq   0

datasize equ $ - $$