# MMDSP
multi music status display MMDSP

This program was named MMDSP (Multi Music Status Display & Selector).
It is a real time display & file selector that supports various music drivers that run on SHARP X68000.

MMDSP supports five types of music drivers: MXDRV, MADRV, RCD, MLD, and ZMUSIC.

You can enjoy functions such as semi-transparency of the background graphic screen (512 * 512 65536 color mode), partial transparency (by GRAM bit 15), and so on.

MMDSP has continuous playback function.
You can enjoy auto / random / simple program play easily without creating a data file.

You can reside and call it at any time with XF4 + XF5 key. (Specified on the command line)

MMDSP is characterized by a realistic movement spectrum analyzer, but when you play PCM8 compatible data on a 10 MHz model, the operation may be slightly heavy depending on the data.

# How to build

## 1. Please configure makefile according to your environment.

    AS	= a:/usr/asm/as.x
    ASFLAGS	= -w -u
    LD	= a:/usr/asm/lk.x

## 2.make

    A\> make
