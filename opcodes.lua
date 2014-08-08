
-- Opcode flags
ASM.OPFLAGS = {}
ASM.OPFLAGS.o16 = 0x01
ASM.OPFLAGS.o32 = 0x02
ASM.OPFLAGS.o64 = 0x03

local opflags = ASM.OPFLAGS

-- Bytecode:
-- o16 - Optional 0x66 prefix
-- o32 - Optional 0x66 prefix
-- o64 - Optional REX.W prefix

-- olk - Optional lock prefix
-- lck - Mandatory lock prefix

-- rb, rw, rd, rq - Register value added to last byte of bytecode
-- ib, iw, id, iq - Immediate value
-- db, dw, dd, dq - Displacement value
-- cb, cw, cd, cp, co, ct - Code offset

-- rm - Mod R/M and possible SIB byte

-- Opcode encoding:
-- M - r/m part of ModRM
-- R - reg part of ModRM
-- I - immX
-- - - Not encoded
-- D - moffs

-- THIS is a big list
-- flags is the only optional entry
ASM.OPCODES_RAW = {
	--AAA
	--AAD
	--AAM
	--AAS
	{"ADC", 2, {"AL","imm8"},	"-i", "14 ib"},
	{"ADC", 2, {"AX","imm16"},	"-i", "o16 15 iw"},
	{"ADC", 2, {"EAX","imm32"}, "-i", "o32 15 id"},
	{"ADC", 2, {"RAX","imm64"}, "-i", "rxW 15 id"},
	{"ADC", 2, {"rm8","imm8"},	"mi", "80 /2 ib"},
	{"ADC", 2, {"rm16","imm16"},"mi", "o16 81 /2 iw"},
	{"ADC", 2, {"rm32","imm32"},"mi", "o32 81 /2 id"},
	{"ADC", 2, {"rm64","imm32"},"mi", "rxW 81 /2 id"},
	{"ADC", 2, {"rm16","imm8"}, "mi", "o16 83 /2 ib"},
	{"ADC", 2, {"rm32","imm8"}, "mi", "o32 83 /2 ib"},
	{"ADC", 2, {"rm64","imm8"}, "mi", "rxW 83 /2 ib"},
	{"ADC", 2, {"rm8","r8"},	"mr", "10 /r"},
	{"ADC", 2, {"rm16","r16"},	"mr", "o16 11 /r"},
	{"ADC", 2, {"rm32","r32"},	"mr", "o32 11 /r"},
	{"ADC", 2, {"rm64","r64"},	"mr", "rxW 11 /r"},
	{"ADC", 2, {"r8","rm8"},	"rm", "12 /r"},
	{"ADC", 2, {"r16","rm16"},	"rm", "o16 12 /r"},
	{"ADC", 2, {"r32","rm32"},	"rm", "o32 12 /r"},
	{"ADC", 2, {"r64","rm64"},	"rm", "rxW 12 /r"},
	
	{"ADD", 2, {"AL","imm8"},	"-i", "04 ib"},
	{"ADD", 2, {"AX","imm16"},	"-i", "o16 05 iw"},
	{"ADD", 2, {"EAX","imm32"}, "-i", "o32 05 id"},
	{"ADD", 2, {"RAX","imm32"}, "-i", "rxW 05 id"},
	{"ADD", 2, {"rm8","imm8"},	"mi", "80 /0 ib"},
	{"ADD", 2, {"rm16","imm16"},"mi", "o16 81 /0 iw"},
	{"ADD", 2, {"rm32","imm32"},"mi", "o32 81 /0 id"},
	{"ADD", 2, {"rm64","imm32"},"mi", "rxW 81 /0 id"},
	{"ADD", 2, {"rm16","imm8"}, "ri", "o16 83 /0 ib"},
	{"ADD", 2, {"rm32","imm8"}, "ri", "o32 83 /0 ib"},
	{"ADD", 2, {"rm64","imm8"}, "ri", "rxW 83 /0 ib"},
	{"ADD", 2, {"rm8","r8"},	"mr", "00 /r"},
	{"ADD", 2, {"rm16","r16"},	"mr", "o16 01 /r"},
	{"ADD", 2, {"rm32","r32"},	"mr", "o32 01 /r"},
	{"ADD", 2, {"rm64","r64"},	"mr", "rxW 01 /r"},
	{"ADD", 2, {"r8","rm8"},	"rm", "02 /r"},
	{"ADD", 2, {"r16","rm16"},	"rm", "o16 03 /r"},
	{"ADD", 2, {"r32","rm32"},	"rm", "o32 03 /r"},
	{"ADD", 2, {"r64","rm64"},	"rm", "rxW 03 /r"},
	
	--ADDPD
	--ADDPS
	--ADDSD
	--ADDSS
	--ADDSUBPD
	--ADDSUBPS
	--AESDEC
	--AESDECLAST
	--AESENC
	--AESENCLAST
	--AESIMC
	--AESKEYGENASSIT
	
	{"AND", 2, {"AL","imm8"},	"-i", "24 ib"},
	{"AND", 2, {"AX","imm16"},	"-i", "o16 25 iw"},
	{"AND", 2, {"EAX","imm32"}, "-i", "o32 25 id"},
	{"AND", 2, {"RAX","imm64"}, "-i", "rxW 25 id"},
	{"AND", 2, {"rm8","imm8"},	"mi", "80 /4 ib"},
	{"AND", 2, {"rm16","imm16"},"mi", "o16 81 /4 iw"},
	{"AND", 2, {"rm32","imm32"},"mi", "o32 81 /4 id"},
	{"AND", 2, {"rm64","imm64"},"mi", "rxW 81 /4 id"},
	{"AND", 2, {"rm16","imm8"}, "mi", "o16 83 /4 ib"},
	{"AND", 2, {"rm32","imm8"}, "mi", "o32 83 /4 ib"},
	{"AND", 2, {"rm64","imm8"}, "mi", "rxW 83 /4 ib"},
	{"AND", 2, {"rm8","r8"},	"mr", "20 /r"},
	{"AND", 2, {"rm16","r16"},	"mr", "o16 21 /r"},
	{"AND", 2, {"rm32","r32"},	"mr", "o32 21 /r"},
	{"AND", 2, {"rm64","r64"},	"mr", "rxW 21 /r"},
	{"AND", 2, {"r8","rm8"},	"rm", "22 /r"},
	{"AND", 2, {"r16","rm16"},	"rm", "o16 23 /r"},
	{"AND", 2, {"r32","rm32"},	"rm", "o32 23 /r"},
	{"AND", 2, {"r64","rm64"},	"rm", "rxW 23 /r"},
	
	-- ANDPD
	-- ANDPS
	-- ANDNPD
	-- ANDNPS
	
	{"ARPL", 2, {"rm16","r16"}, "mr", "63 /r"},
	
	-- BLENDPD
	-- BLENDPS
	-- BLENDVPD
	-- BLENDVPS
	
	{"BOUND", 2, {"r16","m16:16"}, "rm", "o16 62 /r"},
	{"BOUND", 2, {"r32","m32:32"}, "rm", "o32 62 /r"},
	
	{"BSF", 2, {"r16","rm16"},	"rm", "o16 0F BC /r"},
	{"BSF", 2, {"r32","rm32"},	"rm", "o32 0F BC /r"},
	{"BSF", 2, {"r64","rm64"},	"rm", "rxW 0F BC /r"},
	
	{"BSR", 2, {"r16","rm16"},	"rm", "o16 0F BD /r"},
	{"BSR", 2, {"r32","rm32"},	"rm", "o32 0F BD /r"},
	{"BSR", 2, {"r64","rm64"},	"rm", "rxW 0F BD /r"},

	{"BSWAP", 1, {"r32"},		"r", "0F C8 rd"},
	{"BSWAP", 1, {"r64"},		"r", "rxW 0F C8 rd"},
	
	{"BT", 2, {"rm16","r16"},	"mr", "o16 0F A3 /r"},
	{"BT", 2, {"rm32","r32"},	"mr", "o32 0F A3 /r"},
	{"BT", 2, {"rm64","r64"},	"mr", "rxW 0F A3 /r"},
	{"BT", 2, {"rm16","imm8"},	"mi", "o16 0F BA /4 ib"},
	{"BT", 2, {"rm32","imm8"},	"mi", "o32 0F BA /4 ib"},
	{"BT", 2, {"rm64","imm8"},	"mi", "rxW 0F BA /4 ib"},
	
	{"BTC", 2, {"rm16","r16"},	"mr", "o16 0F BB /r"},
	{"BTC", 2, {"rm32","r32"},	"mr", "o32 0F BB /r"},
	{"BTC", 2, {"rm64","r64"},	"mr", "rxW 0F BB /r"},
	{"BTC", 2, {"rm16","imm8"},	"mi", "o16 0F BA /7 ib"},
	{"BTC", 2, {"rm32","imm8"},	"mi", "o32 0F BA /7 ib"},
	{"BTC", 2, {"rm64","imm8"},	"mi", "rxW 0F BA /7 ib"},
	
	{"BTR", 2, {"rm16","r16"},	"mr", "o16 0F B3 /r"},
	{"BTR", 2, {"rm32","r32"},	"mr", "o32 0F B3 /r"},
	{"BTR", 2, {"rm64","r64"},	"mr", "rxW 0F B3 /r"},
	{"BTR", 2, {"rm16","imm8"},	"mi", "o16 0F BA /6 ib"},
	{"BTR", 2, {"rm32","imm8"}, "mi", "o32 0F BA /6 ib"},
	{"BTR", 2, {"rm64","imm8"}, "mi", "rxW 0F BA /6 ib"},
	
	{"BTS", 2, {"rm16","r16"},	"mr", "o16 0F AB /r"},
	{"BTS", 2, {"rm32","r32"},	"mr", "o32 0F AB /r"},
	{"BTS", 2, {"rm64","r64"},	"mr", "rxW 0F AB /r"},
	{"BTS", 2, {"rm16","imm8"},	"mi", "o16 0F BA /5 ib"},
	{"BTS", 2, {"rm32","imm8"}, "mi", "o32 0F BA /5 ib"},
	{"BTS", 2, {"rm64","imm8"}, "mi", "rxW 0F BA /5 ib"},
	
	{"CALLN", 1, {"rel16"},		"m", "o16 E8 cw"},
	{"CALLN", 1, {"rel32"},		"m", "o32 E8 cd"},
	
	{"CALL", 1, {"rm16"},		"m", "o16 FF /2"},
	{"CALL", 1, {"rm32"},		"m", "o32 FF /2"},
	{"CALL", 1, {"rm64"},		"m", "rxW FF /2"},
	
	{"CALLF", 1, {"ptr16:16"},	"d", "o16 9A cd"},
	{"CALLF", 1, {"ptr16:32"},	"d", "o32 9A cp"},
	{"CALLF", 1, {"m16:16"},	"m", "o16 FF /3"},
	{"CALLF", 1, {"m16:32"},	"m", "o32 FF /3"},
	{"CALLF", 1, {"m16:64"},	"m", "rxW FF /3"},
	
	{"CBW", 0, {}, "", "o16 98"},
	{"CWDE", 0, {}, "", "o32 98"},
	{"CDQE", 0, {}, "", "rxW 98"},
	
	{"CLC", 0, {}, "", "F8"},
	{"CLD", 0, {}, "", "FC"},
	{"CLFLUSH", 1, {"m8"}, "", "OF AE /7"},
	{"CLI", 0, {}, "", "FA"},
	{"CLTS", 0, {}, "", "0F 06"},
	{"CMC", 0, {}, "", "F5"},
	
	{"CMOVA", 2, {"r16","rm16"}, "rm", "o16 0F 47 /r"},
	{"CMOVA", 2, {"r32","rm32"}, "rm", "o32 0F 47 /r"},
	{"CMOVA", 2, {"r64","rm64"}, "rm", "rxW 0F 47 /r"},
	{"CMOVAE", 2, {"r16","rm16"}, "rm", "o16 0F 43 /r"},
	{"CMOVAE", 2, {"r32","rm32"}, "rm", "o32 0F 43 /r"},
	{"CMOVAE", 2, {"r64","rm64"}, "rm", "rxW 0F 43 /r"},
	{"CMOVB", 2, {"r16","rm16"}, "rm", "o16 0F 42 /r"},
	{"CMOVB", 2, {"r32","rm32"}, "rm", "o32 0F 42 /r"},
	{"CMOVB", 2, {"r64","rm64"}, "rm", "rxW 0F 42 /r"},
	{"CMOVBE", 2, {"r16","rm16"}, "rm", "o16 0F 46 /r"},
	{"CMOVBE", 2, {"r32","rm32"}, "rm", "o32 0F 46 /r"},
	{"CMOVBE", 2, {"r64","rm64"}, "rm", "rxW 0F 46 /r"},
	{"ALIAS","CMOVC","CMOVB"},
	{"CMOVE", 2, {"r16","rm16"}, "rm", "o16 0F 44 /r"},
	{"CMOVE", 2, {"r32","rm32"}, "rm", "o32 0F 44 /r"},
	{"CMOVE", 2, {"r64","rm64"}, "rm", "rxW 0F 44 /r"},
	{"CMOVG", 2, {"r16","rm16"}, "rm", "o16 0F 4F /r"},
	{"CMOVG", 2, {"r32","rm32"}, "rm", "o32 0F 4F /r"},
	{"CMOVG", 2, {"r64","rm64"}, "rm", "rxW 0F 4F /r"},
	{"CMOVGE", 2, {"r16","rm16"}, "rm", "o16 0F 4D /r"},
	{"CMOVGE", 2, {"r32","rm32"}, "rm", "o32 0F 4D /r"},
	{"CMOVGE", 2, {"r64","rm64"}, "rm", "rxW 0F 4D /r"},
	{"CMOVL", 2, {"r16","rm16"}, "rm", "o16 0F 4C /r"},
	{"CMOVL", 2, {"r32","rm32"}, "rm", "o32 0F 4C /r"},
	{"CMOVL", 2, {"r64","rm64"}, "rm", "rxW 0F 4C /r"},
	{"CMOVLE", 2, {"r16","rm16"}, "rm", "o16 0F 4E /r"},
	{"CMOVLE", 2, {"r32","rm32"}, "rm", "o32 0F 4E /r"},
	{"CMOVLE", 2, {"r64","rm64"}, "rm", "rxW 0F 4E /r"},
	{"ALIAS","CMOVNA","CMOVBE"},
	{"ALIAS","CMOVNAE","CMOVB"},
	{"ALIAS","CMOVNB","CMOVAE"},
	{"ALIAS","CMOVNBE","CMOVA"},
	{"ALIAS","CMOVNC","CMOVAE"},
	{"CMOVNE", 2, {"r16","rm16"}, "rm", "o16 0F 45 /r"},
	{"CMOVNE", 2, {"r32","rm32"}, "rm", "o32 0F 45 /r"},
	{"CMOVNE", 2, {"r64","rm64"}, "rm", "rxW 0F 45 /r"},
	{"ALIAS","CMOVNG","CMOVLE"},
	{"ALIAS","CMOVNGE","CMOVL"},
	{"ALIAS","CMOVNL","CMOVGE"},
	{"ALIAS","CMOVNLE","CMOVG"},
	{"CMOVNO", 2, {"r16","rm16"}, "rm", "o16 0F 41 /r"},
	{"CMOVNO", 2, {"r32","rm32"}, "rm", "o32 0F 41 /r"},
	{"CMOVNO", 2, {"r64","rm64"}, "rm", "rxW 0F 41 /r"},
	{"CMOVNP", 2, {"r16","rm16"}, "rm", "o16 0F 4B /r"},
	{"CMOVNP", 2, {"r32","rm32"}, "rm", "o32 0F 4B /r"},
	{"CMOVNP", 2, {"r64","rm64"}, "rm", "rxW 0F 4B /r"},
	{"CMOVNS", 2, {"r16","rm16"}, "rm", "o16 0F 49 /r"},
	{"CMOVNS", 2, {"r32","rm32"}, "rm", "o32 0F 49 /r"},
	{"CMOVNS", 2, {"r64","rm64"}, "rm", "rxW 0F 49 /r"},
	{"ALIAS","CMOVNZ","CMOVNE"},
	{"CMOVO", 2, {"r16","rm16"}, "rm", "o16 0F 40 /r"},
	{"CMOVO", 2, {"r32","rm32"}, "rm", "o32 0F 40 /r"},
	{"CMOVO", 2, {"r64","rm64"}, "rm", "rxW 0F 40 /r"},
	{"CMOVP", 2, {"r16","rm16"}, "rm", "o16 0F 4A /r"},
	{"CMOVP", 2, {"r32","rm32"}, "rm", "o32 0F 4A /r"},
	{"CMOVP", 2, {"r64","rm64"}, "rm", "rxW 0F 4A /r"},
	{"ALIAS","CMOVPE","CMOVP"},
	{"CMOVPO", 2, {"r16","rm16"}, "rm", "o16 0F AB /r"},
	{"CMOVPO", 2, {"r32","rm32"}, "rm", "o32 0F AB /r"},
	{"CMOVPO", 2, {"r64","rm64"}, "rm", "rxW 0F AB /r"},
	{"CMOVS", 2, {"r16","rm16"}, "rm", "o16 0F 48 /r"},
	{"CMOVS", 2, {"r32","rm32"}, "rm", "o32 0F 48 /r"},
	{"CMOVS", 2, {"r64","rm64"}, "rm", "rxW 0F 48 /r"},
	{"ALIAS","CMOVZ","CMOVE"},
	
	{"CMP", 2, {"AL","imm8"},	"-i", "3C ib"},
	{"CMP", 2, {"AX","imm16"},	"-i", "o16 3D iw"},
	{"CMP", 2, {"EAX","imm32"}, "-i", "o32 3D id"},
	{"CMP", 2, {"RAX","imm32"}, "-i", "rxW 3D id"},
	{"CMP", 2, {"rm8","imm8"}, 	"mi", "80 /7 ib"},
	{"CMP", 2, {"rm16","imm16"},"mi", "o16 81 /7 iw"},
	{"CMP", 2, {"rm32","imm32"},"mi", "o32 81 /7 id"},
	{"CMP", 2, {"rm64","imm32"},"mi", "rxW 81 /7 id"},
	{"CMP", 2, {"rm16","imm8"}, "mi", "o16 83 /7 ib"},
	{"CMP", 2, {"rm32","imm8"}, "mi", "o32 83 /7 ib"},
	{"CMP", 2, {"rm64","imm8"}, "mi", "rxW 83 /7 ib"},
	{"CMP", 2, {"rm8","r8"},	"mr", "38 /r"},
	{"CMP", 2, {"rm16","r16"},	"mr", "o16 39 /r"},
	{"CMP", 2, {"rm32","r32"},	"mr", "o32 39 /r"},
	{"CMP", 2, {"rm64","r64"},	"mr", "rxW 39 /r"},
	{"CMP", 2, {"r8","rm8"},	"rm", "3A /r"},
	{"CMP", 2, {"r16","rm16"},	"rm", "o16 3A /r"},
	{"CMP", 2, {"r32","rm32"},	"rm", "o32 3A /r"},
	{"CMP", 2, {"r64","rm64"},	"rm", "rxW 3A /r"},
	
	--CMPPD
	--CMPPS
	
	{"CMPSB", 0, {}, "", "A6"},
	{"CMPSW", 0, {}, "", "o16 A7"},
	{"CMPSD", 0, {}, "", "o32 A7"},
	{"CMPSQ", 0, {}, "", "rxW A7"},
	
	--CMPSD
	--CMPSS
	
	{"CMPXCHG", 2, {"rm8","r8"}, "mr", "0F B0 /r"},
	{"CMPXCHG", 2, {"rm16","r16"}, "mr", "o16 0F B1 /r"},
	{"CMPXCHG", 2, {"rm32","r32"}, "mr", "o32 0F B1 /r"},
	{"CMPXCHG", 2, {"rm64","r64"}, "mr", "rxW 0F B1 /r"},
	
	--CMPXCHG8B/CMPXCHG16B
	--COMISD
	--COMISS
	
	{"CPUID", 0, {}, "", "0F A2"},
	
	--CRC32
	--CVTDQ2PD - CVTTSS2SI
	
	{"CWD", 0, {}, "", "o16 99"},
	{"CDQ", 0, {}, "", "o32 99"},
	{"CQO", 0, {}, "", "rxW 99"},
	
	{"DAA", 0, {}, "", "27"},
	{"DAS", 0, {}, "", "2F"},
	
	{"DEC", 1, {"rm8"}, "m", "FE /1"},
	{"DEC", 1, {"rm16"}, "m", "o16 FF /1"},
	{"DEC", 1, {"rm32"}, "m", "o32 FF /1"},
	{"DEC", 1, {"rm64"}, "m", "rxW FF /1"},
	{"DEC", 1, {"r16"}, "r", "o16 48 rw"},
	{"DEC", 1, {"r32"}, "r", "o32 48 rd"},
	
	{"DIV", 1, {"rm8"}, "m", "F6 /6"},
	{"DIV", 1, {"rm16"}, "m", "o16 F7 /6"},
	{"DIV", 1, {"rm32"}, "m", "o32 F7 /6"},
	{"DIV", 1, {"rm64"}, "m", "rxW F7 /6"},
	
	--DIVPD - EMMS
	
	{"ENTER", 2, {"imm16","imm8"}, "ii", "C8 iw ib"},
	
	--EXTRACTPS
	--F2XM1 - HADDPS
	
	{"HLT", 0, {}, "", "F4"},
	
	-- HSUBPD
	-- HSUBPS
	
	{"IDIV", 1, {"rm8"}, "m", "F6 /7"},
	{"IDIV", 1, {"rm16"}, "m", "o16 F7 /7"},
	{"IDIV", 1, {"rm32"}, "m", "o32 F7 /7"},
	{"IDIV", 1, {"rm64"}, "m", "rxW F7 /7"},
	
	{"IMUL", 1, {"rm8"}, "m", "F6 /5"},
	{"IMUL", 1, {"rm16"}, "m", "o16 F7 /5"},
	{"IMUL", 1, {"rm32"}, "m", "o32 F7 /5"},
	{"IMUL", 1, {"rm64"}, "m", "rxW F7 /5"},
	{"IMUL", 2, {"r16","rm16"}, "m", "o16 0F AF /r"},
	{"IMUL", 2, {"r32","rm32"}, "m", "o32 0F AF /r"},
	{"IMUL", 2, {"r64","rm64"}, "m", "rxW 0F AF /r"},
	{"IMUL", 3, {"r16","rm16","imm8"}, "rmi", "o16 6B /r ib"},
	{"IMUL", 3, {"r32","rm32","imm8"}, "rmi", "o32 6B /r ib"},
	{"IMUL", 3, {"r64","rm64","imm8"}, "rmi", "rxW 6B /r ib"},
	{"IMUL", 3, {"r16","rm16","imm16"}, "rmi", "o16 69 /r iw"},
	{"IMUL", 3, {"r32","rm32","imm32"}, "rmi", "o32 69 /r id"},
	{"IMUL", 3, {"r64","rm64","imm32"}, "rmi", "rxW 69 /r id"},
	
	{"IN", 2, {"AL","imm8"}, "-i", "E4 ib"},
	{"IN", 2, {"AX","imm8"}, "-i", "o16 E5 ib"},
	{"IN", 2, {"EAX","imm8"}, "-i", "o32 E5 ib"},
	{"IN", 2, {"AL","DX"}, "", "EC"},
	{"IN", 2, {"AX","DX"}, "", "o16 ED"},
	{"IN", 2, {"EAX","DX"}, "", "o32 ED"},
	
	{"INC", 1, {"rm8"}, "m", "FE /0"},
	{"INC", 1, {"rm16"}, "m", "o16 FF /0"},
	{"INC", 1, {"rm32"}, "m", "o32 FF /0"},
	{"INC", 1, {"rm64"}, "m", "rxW FF /0"},
	{"INC", 1, {"r16"}, "r", "o16 40 rw"},
	{"INC", 1, {"r32"}, "r", "o32 40 rd"},
	
	{"INSB", 0, {}, "", "6C"},
	{"INSW", 0, {}, "", "o16 INSW"},
	{"INSD", 0, {}, "", "o32 INSD"},
	
	--INSERTPS
	
	{"INT", 1, {"3"}, "", "CC"},
	{"INT", 1, {"imm8"}, "i", "CD ib"},
	{"INTO", 0, {}, "", "CE"},
	
	{"INVD", 0, {}, "", "0F 08"},
	--INVLPG, INVPCID
	
	{"IRET", 0, {}, "", "o16 CF"},
	{"IRETD", 0, {}, "", "o32 CF"},
	{"IRETQ", 0, {}, "", "rxW CF"},

	{"MOV", 2, {"r8","r8"}, 	"mr", "88 /r"},
	{"MOV", 2, {"m8","r8"}, 	"mr", "88 /r"},
	{"MOV", 2, {"r16","r16"}, 	"mr", "o16 89 /r"},
	{"MOV", 2, {"m16","r16"}, 	"mr", "o16 89 /r"},
	{"MOV", 2, {"r32","r32"}, 	"mr", "o32 89 /r"},
	{"MOV", 2, {"m32","r32"}, 	"mr", "o32 89 /r"},
	{"MOV", 2, {"r8","m8"},		"rm", "8A /r"},
	{"MOV", 2, {"r16","m16"},	"rm", "o16 8B /r"},
	{"MOV", 2, {"r32","m32"},	"rm", "o32 8B /r"},
	{"MOV", 2, {"r8","imm8"},	"ri", "B0 rb ib"},
	{"MOV", 2, {"r16","imm16"}, "ri", "o16 B8 rw iw"},
	{"MOV", 2, {"AX","moffs16"},"-d", "o16 A1 dw"},
	
	{"MOVSB", 0, {}, "", "A4"},
	{"MOVSW", 0, {}, "", "o16 A5"},
	{"MOVSD", 0, {}, "", "o32 A5"},
	{"MOVSQ", 0, {}, "", "rxW A5"},
}

ASM.OPCODES = {}

-- Initialize opcode table
for _, opcode in pairs(ASM.OPCODES_RAW) do
	name = opcode[1]
	if name == "ALIAS" then
		opname = opcode[2]
		op2name = opcode[3]
		
		ASM.OPCODE[opname] = ASM.OPCODE[op2name]
	else
		nOperands = opcode[2]
		operands = opcode[3]
		bytecode = opcode[4]
		flags = opcode[5] or 0
		ASM.OPCODES[name] = ASM.OPCODES[name] or {}
		ASM.OPCODES[name][nOperands] = ASM.OPCODES[name][nOperands] or {}
		
		local tmp = ASM.OPCODES[name][nOperands]
		-- Special case for 0 operand stuff
		if nOperands > 0 then
			local tmp2 = tmp
			local tmp3 = tmp2
			local lv = nil
			for i,v in pairs(operands) do
				tmp2[v] = tmp2[v] or {}
				tmp3 = tmp2
				lv = v
				tmp2 = tmp2[v]
			end
			tmp3[lv] = {bytecode, flags}
		else
			ASM.OPCODES[name][nOperands] = {bytecode, flags}
		end
	end
end