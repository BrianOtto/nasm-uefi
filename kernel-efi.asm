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
EFI_SUCCESS                equ 0
EFI_LOAD_ERROR             equ 0x8000000000000001
EFI_SYSTEM_TABLE_SIGNATURE equ 0x5453595320494249

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
    .TestString	       POINTER
    .QueryMode	       POINTER
    .SetMode	       POINTER
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
    
    ret