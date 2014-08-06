LuaASM
======

An x86 architecture assembler written in Lua. LuaASM uses the Intel syntax.
The first release capable version will most likely not include support
for 64-bit (i.e. Long Mode).

TODO:
 - Finish encoding
 - Write a C host for the assembler
 - Write a binary IO Lua library
 - Re-implement the bit library to support 64-bits
 - Write the complete Instruction Opcode table

Command Line
============

(This will change when the C host is introduced)
lua.exe LuaASM/asm.lua [ -I <includeDir> ] <Source files...>

Switches:
 -I <includeDir> : Adds a *single* directory to the include search path

Copyright
=========

This software is a work of Anthony Wilkins and is under the GPL v3 license.
