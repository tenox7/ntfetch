# Makefile - ntfetch for Windows NT 3.1 and later: nmake
# Builds with the NT 3.1 SDK or any Visual C++, with the flags each one needs.

# MSC = _MSC_VER of the cl in PATH: 800 NT 3.1 SDK, 900 VC++ 2.0, 1020 VC++ 4.2, 1200 VC++ 6.0, 1400 VS2005 ...
!IF [echo MSC = _MSC_VER > msc.c] == 0 && [cl -nologo -EP -P msc.c > nul 2>&1] == 0
!INCLUDE msc.i
!ENDIF
!IF [del msc.?]
!ENDIF
!IFNDEF MSC
!ERROR cl not found
!ENDIF

# the SDK's setenv sets CPU: i386, MIPS or ALPHA
!IFNDEF CPU
CPU = i386
!ENDIF

CFLAGS = -c -nologo -W3 -Ox -DWIN32
LD = link
LFLAGS = -nologo -release -subsystem:windows
LIBS = kernel32.lib user32.lib gdi32.lib advapi32.lib
RES = ntfetch.res

!IF $(MSC) < 900
# NT 3.1 SDK: link32 wants the resources through cvtres, and knows no -nologo or -release
LD = link32
LFLAGS = -subsystem:windows -entry:WinMainCRTStartup
LIBS = libc.lib $(LIBS)
RES = ntfetch.rbj
!ENDIF
!IF $(MSC) >= 1400
# VS2005 and later: no security cookie (-GS-), which the Windows 7 SDK's IA64 build complains about, and no .manifest file
CFLAGS = $(CFLAGS) -GS-
LFLAGS = $(LFLAGS) -manifest:no
!ENDIF

all: ntfetch.exe

ntfetch.exe: ntfetch.obj $(RES)
	$(LD) $(LFLAGS) -out:ntfetch.exe ntfetch.obj $(RES) $(LIBS)

ntfetch.obj: ntfetch.c resource.h
	cl $(CFLAGS) ntfetch.c

ntfetch.res: ntfetch.rc resource.h icons\ntfetch.ico icons\x86.ico icons\x64.ico icons\mips.ico icons\axp.ico icons\axp64.ico icons\ppc.ico icons\arm.ico icons\arm64.ico icons\ia64.ico icons\r3000.ico
	rc -r -fo ntfetch.res ntfetch.rc

ntfetch.rbj: ntfetch.res
	cvtres -$(CPU) ntfetch.res -o ntfetch.rbj

clean:
	-del ntfetch.obj
	-del ntfetch.res
	-del ntfetch.rbj
	-del ntfetch.exe
