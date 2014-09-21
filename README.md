LuaASM
======

An x86 architecture assembler written in Lua. LuaASM uses the Intel syntax.
The first release capable version will most likely not include support
for 64-bit (i.e. Long Mode).

TODO:
 - Refine encoding (everything except for fine details of effective addressing should be complete)
 - Write a C host for the assembler
 - Re-implement the bit library to support 64-bits
 - Add support for instruction set extensions (base x86 set is finished)

For all intents and purposes this assembler should be functioning. Only flat binary outputs are supported and
no extensions to the x86 instruction set are implemented. The assembler may not give the most optimal effective
address, effective address encoding still needs refining. Sorry about the absence, quite busy this month.

Please do suggest features and report bugs!

Command Line
============

(This will change when the C host is introduced)

lua.exe LuaASM/asm.lua [ -I \<includeDir\> ] [-f \<format\>] [-o \<fname\>] \<Source files...\>

Switches:
 * -I \<includeDir\> : Adds a *single* directory to the include search path
 * -f \<format\> : Sets the output format
 * -o \<fname\> : Set the output filename
 
Output Formats:
 - bin - Flat binary

Copyright
=========

This software is a work of Anthony Wilkins and is under the GPL v3 license.

Notes
=====


