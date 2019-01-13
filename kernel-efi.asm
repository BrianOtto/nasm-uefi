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

; the UEFI definitions we use in our application
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G45.1342862
EFI_SUCCESS                       equ 0
EFI_LOAD_ERROR                    equ 0x8000000000000001 ; 9223372036854775809
EFI_INVALID_PARAMETER             equ 0x8000000000000002 ; 9223372036854775810
EFI_UNSUPPORTED                   equ 0x8000000000000003 ; 9223372036854775811
EFI_BAD_BUFFER_SIZE               equ 0x8000000000000004 ; 9223372036854775812
EFI_BUFFER_TOO_SMALL              equ 0x8000000000000005 ; 9223372036854775813
EFI_NOT_READY                     equ 0x8000000000000006 ; 9223372036854775814
EFI_NOT_FOUND                     equ 0x8000000000000014 ; 9223372036854775828

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G8.1001773
EFI_SYSTEM_TABLE_SIGNATURE        equ 0x5453595320494249

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G16.1018812
EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID db 0xde, 0xa9, 0x42, 0x90, 0xdc, 0x23, 0x38, 0x4a
                                  db 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a

; the UEFI data types with natural alignment set
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G6.999718
%macro UINTN 0
    RESQ 1
    alignb 8
%endmacro

%macro UINT32 0
    RESD 1
    alignb 4
%endmacro

%macro UINT64 0
    RESQ 1
    alignb 8
%endmacro

%macro EFI_HANDLE 0
    RESQ 1
    alignb 8
%endmacro

%macro POINTER 0
    RESQ 1
    alignb 8
%endmacro

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G8.1001729
struc EFI_TABLE_HEADER
    .Signature  UINT64
    .Revision   UINT32
    .HeaderSize UINT32
    .CRC32      UINT32
    .Reserved   UINT32
endstruc

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G8.1001773
struc EFI_SYSTEM_TABLE
    .Hdr                  RESB EFI_TABLE_HEADER_size
    .FirmwareVendor       POINTER
    .FirmwareRevision     UINT32
    .ConsoleInHandle      EFI_HANDLE
    .ConIn                POINTER
    .ConsoleOutHandle     EFI_HANDLE
    .ConOut               POINTER
    .StandardErrorHandle  EFI_HANDLE
    .StdErr               POINTER
    .RuntimeServices      POINTER
    .BootServices         POINTER
    .NumberOfTableEntries UINTN
    .ConfigurationTable   POINTER
endstruc

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G16.1016807
struc EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    .Reset             POINTER
    .OutputString      POINTER
    .TestString        POINTER
    .QueryMode         POINTER
    .SetMode           POINTER
    .SetAttribute      POINTER
    .ClearScreen       POINTER
    .SetCursorPosition POINTER
    .EnableCursor      POINTER
    .Mode              POINTER
endstruc

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G8.1001843
struc EFI_BOOT_SERVICES
    .Hdr                                 RESB EFI_TABLE_HEADER_size
    .RaiseTPL                            POINTER
    .RestoreTPL                          POINTER
    .AllocatePages                       POINTER
    .FreePages                           POINTER
    .GetMemoryMap                        POINTER
    .AllocatePool                        POINTER
    .FreePool                            POINTER
    .CreateEvent                         POINTER
    .SetTimer                            POINTER
    .WaitForEvent                        POINTER
    .SignalEvent                         POINTER
    .CloseEvent                          POINTER
    .CheckEvent                          POINTER
    .InstallProtocolInterface            POINTER
    .ReinstallProtocolInterface          POINTER
    .UninstallProtocolInterface          POINTER
    .HandleProtocol                      POINTER
    .Reserved                            POINTER
    .RegisterProtocolNotify              POINTER
    .LocateHandle                        POINTER
    .LocateDevicePath                    POINTER
    .InstallConfigurationTable           POINTER
    .LoadImage                           POINTER
    .StartImage                          POINTER
    .Exit                                POINTER
    .UnloadImage                         POINTER
    .ExitBootServices                    POINTER
    .GetNextMonotonicCount               POINTER
    .Stall                               POINTER
    .SetWatchdogTimer                    POINTER
    .ConnectController                   POINTER
    .DisconnectController                POINTER
    .OpenProtocol                        POINTER
    .CloseProtocol                       POINTER
    .OpenProtocolInformation             POINTER
    .ProtocolsPerHandle                  POINTER
    .LocateHandleBuffer                  POINTER
    .LocateProtocol                      POINTER
    .InstallMultipleProtocolInterfaces   POINTER
    .UninstallMultipleProtocolInterfaces POINTER
    .CalculateCrc32                      POINTER
    .CopyMem                             POINTER
    .SetMem                              POINTER
    .CreateEventEx                       POINTER
endstruc

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G8.1002011
struc EFI_RUNTIME_SERVICES
    .Hdr                       RESB EFI_TABLE_HEADER_size
    .GetTime                   POINTER
    .SetTime                   POINTER
    .GetWakeupTime             POINTER
    .SetWakeupTime             POINTER
    .SetVirtualAddressMap      POINTER
    .ConvertPointer            POINTER
    .GetVariable               POINTER
    .GetNextVariableName       POINTER
    .SetVariable               POINTER
    .GetNextHighMonotonicCount POINTER
    .ResetSystem               POINTER
    .UpdateCapsule             POINTER
    .QueryCapsuleCapabilities  POINTER
    .QueryVariableInfo         POINTER
endstruc

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G16.1018812
struc EFI_GRAPHICS_OUTPUT_PROTOCOL
    .QueryMode POINTER
    .SetMode   POINTER
    .Blt       POINTER
    .Mode      POINTER
endstruc

; see Errata A page 494
struc EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
    .MaxMode         UINT32
    .Mode            UINT32
    .Info            POINTER
    .SizeOfInfo      UINTN
    .FrameBufferBase UINT64
    .FrameBufferSize UINTN
endstruc

; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G11.1004788
; the Related Definitions section
struc EFI_MEMORY_DESCRIPTOR
    .Type          UINT32
    .PhysicalStart POINTER
    .VirtualStart  POINTER
    .NumberOfPages UINT64
    .Attribute     UINT64
endstruc

; ---- Function Wrappers for the Protocols / Services

; we use the same calling conventions as UEFI
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G6.1000069

; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G16.1016966
efiOutputString:
    ; set the 2nd argument to the passed in string
    mov rdx, rcx
    
    ; get the EFI_SYSTEM_TABLE
    mov rcx, [ptrSystemTable]
    
    ; set the 1st argument to EFI_SYSTEM_TABLE.ConOut
    ; which is pointing to EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    mov rcx, [rcx + EFI_SYSTEM_TABLE.ConOut]
    
    ; run EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]
    
    ; display any errors
    cmp rax, EFI_SUCCESS
    jne errorCode
    
    ret

; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G16.1017390
efiClearScreen:
    ; get the EFI_SYSTEM_TABLE
    mov rcx, [ptrSystemTable]
    
    ; set the 1st argument to EFI_SYSTEM_TABLE.ConOut
    ; which is pointing to EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    mov rcx, [rcx + EFI_SYSTEM_TABLE.ConOut]
    
    ; run EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen]
    
    ; display any errors
    cmp rax, EFI_SUCCESS
    jne errorCode
    
    ret

; EFI_BOOT_SERVICES.LocateProtocol
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G11.1006649
efiLocateProtocol:
    ; get the EFI_SYSTEM_TABLE
    mov rax, [ptrSystemTable]
    
    ; get the EFI_SYSTEM_TABLE.BootServices
    ; which is pointing to EFI_BOOT_SERVICES
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]
    
    ; set the 1st argument to the GUID for the graphics protocol
    mov rcx, EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID
    
    ; set the 2nd argument to NULL
    mov rdx, 0
    
    ; set the 3rd argument to a variable that holds 
    ; the returned EFI_GRAPHICS_OUTPUT_PROTOCOL
    lea r8, [ptrInterface]
    
    ; run EFI_BOOT_SERVICES.LocateProtocol
    call [rax + EFI_BOOT_SERVICES.LocateProtocol]
    
    ; display any errors
    cmp rax, EFI_SUCCESS
    jne errorCode
    
    ret

; EFI_BOOT_SERVICES.GetMemoryMap
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G11.1004788
efiGetMemoryMap:
    ; get the EFI_SYSTEM_TABLE
    mov rax, [ptrSystemTable]
    
    ; get the EFI_SYSTEM_TABLE.BootServices
    ; which is pointing to EFI_BOOT_SERVICES
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]
    
    ; set the 1st argument to the memory map buffer size
    lea rcx, [intMemoryMapSize]
    
    ; set the 2nd argument to the memory map buffer
    lea rdx, [bufMemoryMap]
    
    ; set the 3rd argument to a variable that holds 
    ; the returned memory map key
    lea r8, [ptrMemoryMapKey]
    
    ; set the 4th argument to a variable that holds 
    ; the returned EFI_MEMORY_DESCRIPTOR size
    lea r9, [ptrMemoryMapDescSize]
    
    ; set the 5th argument to a variable that holds 
    ; the returned EFI_MEMORY_DESCRIPTOR version
    lea r10, [ptrMemoryMapDescVersion]
    
    ; save the top of the stack so we can return here
    mov rbx, rsp
    
    ; save the 5th argument to the stack
    push r10
    
    ; run EFI_BOOT_SERVICES.GetMemoryMap
    call [rax + EFI_BOOT_SERVICES.GetMemoryMap]
    
    ; display any errors
    cmp rax, EFI_SUCCESS
    jne errorCode
    
    ; return to the previous stack location
    mov rsp, rbx
    
    ret

; EFI_BOOT_SERVICES.ExitBootServices
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G11.1007244
efiExitBootServices:
    ; get the EFI_SYSTEM_TABLE
    mov rax, [ptrSystemTable]
    
    ; get the EFI_SYSTEM_TABLE.BootServices
    ; which is pointing to EFI_BOOT_SERVICES
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]
    
    ; set the 1st argument to the stored EFI_HANDLE
    mov rcx, [hndImageHandle]
    
    ; set the 2nd argument to the memory map key
    mov rdx, [ptrMemoryMapKey]
    
    ; run EFI_BOOT_SERVICES.ExitBootServices
    call [rax + EFI_BOOT_SERVICES.ExitBootServices]
    
    ; display any errors
    cmp rax, EFI_SUCCESS
    jne errorCode
    
    ret