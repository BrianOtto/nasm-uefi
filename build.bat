@ECHO OFF

SET EXITCODE=0
SET EXTRAMSG=

SET MNT="V:\"
SET VHD="%CD%\kernel.vhd"
SET ASM="%CD%\kernel.asm"
SET OBJ="%CD%\kernel.obj"
SET EFI="%CD%\kernel.efi"

SET OVMF="%CD%\OVMF.fd"
SET NASM="C:\Program Files\NASM\nasm"
SET QEMU="C:\Program Files\Qemu\qemu-system-x86_64"

ECHO.
ECHO NASM UEFI Build Script
ECHO.

IF "%VSCMD_ARG_HOST_ARCH%" NEQ "x64" GOTO :ErrorX64
IF "%VSCMD_ARG_TGT_ARCH%" NEQ "x64" GOTO :ErrorX64

NET SESSION > NUL 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorAdmin

ECHO   1) Build Virtual Hard Disk
ECHO   2) Mount / Unmount VHD
ECHO   3) Build UEFI Application
ECHO   4) Build UEFI ^& Boot Machine
ECHO   5) Clean Files
ECHO.

SET /P CHOICE=Choose #

ECHO.

IF %CHOICE% == 1 GOTO :BuildVHD
IF %CHOICE% == 2 GOTO :MountVHD
IF %CHOICE% == 3 GOTO :BuildUEFI
IF %CHOICE% == 4 GOTO :Boot
IF %CHOICE% == 5 GOTO :Clean

ECHO Error: You have entered an invalid #

GOTO :EOF

:ErrorX64

ECHO Error: You must run this script from the x64 Native Tools Command Prompt for VS 2017

GOTO :EOF

:ErrorAdmin

ECHO Error: You must run this script as an Administrator

GOTO :EOF

:BuildVHD
IF EXIST %MNT% CALL :MountVHD
IF %EXITCODE% NEQ 0 GOTO :EOF

IF EXIST %VHD% DEL %VHD%

ECHO create vdisk file=%VHD% maximum=300 > build.tmp
ECHO select vdisk file=%VHD% >> build.tmp
ECHO attach vdisk >> build.tmp
ECHO convert gpt >> build.tmp
ECHO create partition efi size=100 >> build.tmp
ECHO create partition primary >> build.tmp
ECHO format fs=fat32 quick >> build.tmp
ECHO assign letter=V >> build.tmp
ECHO exit >> build.tmp

SET EXTRAMSG=create

GOTO :RunDiskPart

:MountVHD
IF EXIST %MNT% (
    IF EXIST %VHD% (
        ECHO select vdisk file=%VHD% > build.tmp
        ECHO detach vdisk >> build.tmp
        ECHO exit >> build.tmp
        
        SET EXTRAMSG=detach
    ) ELSE (
        ECHO Error: You must build the VHD first
        
        SET EXITCODE=1
        
        GOTO :EOF
    )
) ELSE (
    ECHO select vdisk file=%VHD% > build.tmp
    ECHO attach vdisk >> build.tmp
    ECHO select partition 3 >> build.tmp
    ECHO assign letter=V >> build.tmp
    ECHO exit >> build.tmp
    
    SET EXTRAMSG=attach
)

GOTO :RunDiskPart

:RunDiskPart
DISKPART /S build.tmp > build.err

IF %ERRORLEVEL% NEQ 0 (
    ECHO Error: The diskpart command failed with the following output
    ECHO.
    ECHO ------
    
    TYPE build.err
    DEL build.err
    
    SET EXITCODE=1
) ELSE (
    ECHO VHD Success! ^(%EXTRAMSG%^)
)

DEL build.err
DEL build.tmp

GOTO :EOF

:BuildUEFI
%NASM% -f win64 %ASM% -o %OBJ% > NUL 2> build.err

IF %ERRORLEVEL% NEQ 0 (
    ECHO Error: The nasm command failed with the following output
    ECHO.
    ECHO ------
    ECHO.
    
    TYPE build.err
    DEL build.err
    
    SET EXITCODE=1
    
    GOTO :EOF
)

DEL build.err

link /subsystem:EFI_APPLICATION /entry:_start /out:%EFI% %OBJ% > build.err

IF %ERRORLEVEL% NEQ 0 (
    ECHO Error: The link command failed with the following output
    ECHO.
    ECHO ------
    ECHO.
    
    TYPE build.err
    DEL build.err
    
    SET EXITCODE=1
    
    GOTO :EOF
)

DEL build.err

ECHO EFI Success!

GOTO :EOF

:Boot
IF NOT EXIST %VHD% CALL :BuildVHD && ECHO.
IF %EXITCODE% NEQ 0 GOTO :EOF

IF NOT EXIST %MNT% CALL :MountVHD && ECHO.
IF %EXITCODE% NEQ 0 GOTO :EOF

CALL :BuildUEFI
IF %EXITCODE% NEQ 0 GOTO :EOF

ECHO.

IF NOT EXIST %MNT%EFI MKDIR %MNT%EFI
IF NOT EXIST %MNT%EFI\BOOT MKDIR %MNT%EFI\BOOT

COPY /Y %EFI% %MNT%EFI\BOOT\BOOTX64.EFI > build.err

IF %ERRORLEVEL% NEQ 0 (
    ECHO Error: The copy command failed with the following output
    ECHO.
    ECHO ------
    ECHO.
    
    TYPE build.err
    DEL build.err
    
    SET EXITCODE=1
    
    GOTO :EOF
)

DEL build.err

CALL :MountVHD
IF %EXITCODE% NEQ 0 GOTO :EOF

%QEMU% -cpu qemu64 -bios %OVMF% -drive file=%VHD%,format=raw

GOTO :EOF

:Clean
IF EXIST %MNT% (CALL :MountVHD)

DEL %VHD%
DEL %OBJ%
DEL %EFI%

ECHO Clean!

GOTO :EOF

:EOF
EXIT /B %EXITCODE%