
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
	{"IN", 2, {"AL","DX"}, "--", "EC"},
	{"IN", 2, {"AX","DX"}, "--", "o16 ED"},
	{"IN", 2, {"EAX","DX"}, "--", "o32 ED"},
	
	{"INC", 1, {"rm8"}, "m", "FE /0"},
	{"INC", 1, {"rm16"}, "m", "o16 FF /0"},
	{"INC", 1, {"rm32"}, "m", "o32 FF /0"},
	{"INC", 1, {"rm64"}, "m", "rxW FF /0"},
	{"INC", 1, {"r16"}, "r", "o16 40 rw"},
	{"INC", 1, {"r32"}, "r", "o32 40 rd"},
	
	{"INSB", 0, {}, "", "6C"},
	{"INSW", 0, {}, "", "o16 6D"},
	{"INSD", 0, {}, "", "o32 6D"},
	
	--INSERTPS
	
	{"INT", 1, {"3"}, "", "CC"},
	{"INT", 1, {"imm8"}, "i", "CD ib"},
	{"INTO", 0, {}, "", "CE"},
	
	{"INVD", 0, {}, "", "0F 08"},
	--INVLPG, INVPCID
	
	{"IRET", 0, {}, "", "o16 CF"},
	{"IRETD", 0, {}, "", "o32 CF"},
	{"IRETQ", 0, {}, "", "rxW CF"},
	
	{"JA", 1, {"moffs8"}, "d", "77 cb"},
	{"JAE", 1, {"moffs8"}, "d", "73 cb"},
	{"JB", 1, {"moffs8"}, "d", "72 cb"},
	{"JBE", 1, {"moffs8"}, "d", "76 cb"},
	{"ALIAS", "JC", "JB"},
	{"JCXZ", 1, {"moffs8"}, "d", "o16 E3 cb"},
	{"JECXZ", 1, {"moffs8"}, "d", "o32 E3 cb"},
	{"JRCXZ", 1, {"moffs8"}, "d", "rxW E3 cb"},
	{"JE", 1, {"moffs8"}, "d", "74 cb"},
	{"JG", 1, {"moffs8"}, "d", "7F cb"},
	{"JGE", 1, {"moffs8"}, "d", "7D cb"},
	{"JL", 1, {"moffs8"}, "d", "7C cb"},
	{"JLE", 1, {"moffs8"}, "d", "7E cb"},
	{"JNA", 1, {"moffs8"}, "d", "76 cb"},
	{"JNAE", 1, {"moffs8"}, "d", "72 cb"},
	{"JNB", 1, {"moffs8"}, "d", "73 cb"},
	{"JNBE", 1 {"moffs8"}, "d", "77 cb"},
	{"JNC", 1, {"moffs8"}, "d", "73 cb"},
	{"JNE", 1, {"moffs8"}, "d", "75 cb"},
	{"JNG", 1, {"moffs8"}, "d", "7E cb"},
	{"JNGE", 1, {"moffs8"}, "d", "7C cb"},
	{"JNL", 1, {"moffs8"}, "d", "7D cb"},
	{"JNLE", 1, {"moffs8"}, "d", "7F cb"},
	{"JNO", 1, {"moffs8"}, "d", "71 cb"},
	{"JNP", 1, {"moffs8"}, "d", "7B cb"},
	{"JNS", 1, {"moffs8"}, "d", "79 cb"},
	{"JNZ", 1, {"moffs8"}, "d", "75 cb"},
	{"JO", 1, {"moffs8"}, "d", "70 cb"},
	{"JP", 1, {"moffs8"}, "d", "7A cb"},
	{"JPE", 1, {"moffs8"}, "d", "7A cb"},
	{"JPO", 1, {"moffs8"}, "d", "7B cb"},
	{"JS", 1, {"moffs8"}, "d", "78 cb"},
	{"JZ", 1, {"moffs8"}, "d", "74 cb"},
	{"JA", 1, {"moffs16"}, "d", "o16 0F 87 cw"},
	{"JA", 1, {"moffs32"}, "d", "o32 0F 87 cd"},
	{"JAE", 1, {"moffs16"}, "d", "o16 0F 83 cw"},
	{"JAE", 1, {"moffs32"}, "d", "o32 0F 83 cd"},
	{"JB", 1, {"moffs16"}, "d", "o16 0F 82 cw"},
	{"JB", 1, {"moffs32"}, "d", "o32 0F 82 cd"},
	{"JBE", 1, {"moffs16"}, "d", "o16 0F 86 cw"},
	{"JBE", 1, {"moffs32"}, "d", "o32 0F 86 cd"},
	{"JC", 1, {"moffs16"}, "d", "o16 0F 82 cw"},
	{"JC", 1, {"moffs32"}, "d", "o32 0F 82 cd"},
	{"JE", 1, {"moffs16"}, "d", "o16 0F 84 cw"},
	{"JE", 1, {"moffs32"}, "d", "o32 0F 84 cd"},
	{"JG", 1, {"moffs16"}, "d", "o16 0F 8F cw"},
	{"JG", 1, {"moffs32"}, "d", "o32 0F 8F cd"},
	{"JGE", 1, {"moffs16"}, "d", "o16 0F 8D cw"},
	{"JGE", 1, {"moffs32"}, "d", "o32 0F 8D cd"},
	{"JL", 1, {"moffs16"}, "d", "o16 0F 8C cw"},
	{"JL", 1, {"moffs32"}, "d", "o32 0F 8C cd"},
	{"JLE", 1, {"moffs16"}, "d", "o16 0F 8E cw"},
	{"JLE", 1, {"moffs32"}, "d", "o32 0F 8E cd"},
	{"JNA", 1, {"moffs16"}, "d", "o16 0F 86 cw"},
	{"JNA", 1, {"moffs32"}, "d", "o32 0F 86 cd"},
	{"JNAE", 1, {"moffs16"}, "d", "o16 0F 82 cw"},
	{"JNAE", 1, {"moffs32"}, "d", "o32 0F 82 cd"},
	{"JNB", 1, {"moffs16"}, "d", "o16 0F 83 cw"},
	{"JNB", 1, {"moffs32"}, "d", "o32 0F 83 cd"},
	{"JNBE", 1, {"moffs16"}, "d", "o16 0F 87 cw"},
	{"JNBE", 1, {"moffs32"}, "d", "o32 0F 87 cd"},
	{"JNC", 1, {"moffs16"}, "d", "o16 0F 83 cw"},
	{"JNC", 1, {"moffs32"}, "d", "o32 0F 83 cd"},
	{"JNE", 1, {"moffs16"}, "d", "o16 0F 85 cw"},
	{"JNE", 1, {"moffs32"}, "d", "o32 0F 85 cd"},
	{"JNG", 1, {"moffs16"}, "d", "o16 0F 8E cw"},
	{"JNG", 1, {"moffs32"}, "d", "o32 0F 8E cd"},
	{"JNGE", 1, {"moffs16"}, "d", "o16 0F 8C cw"},
	{"JNGE", 1, {"moffs32"}, "d", "o32 0F 8C cd"},
	{"JNL", 1, {"moffs16"}, "d", "o16 0F 8D cw"},
	{"JNL", 1, {"moffs32"}, "d", "o32 0F 8D cd"},
	{"JNLE", 1, {"moffs16"}, "d", "o16 0F 8F cw"},
	{"JNLE", 1, {"moffs32"}, "d", "o32 0F 8F cd"},
	{"JNO", 1, {"moffs16"}, "d", "o16 0F 81 cw"},
	{"JNO", 1, {"moffs32"}, "d", "o32 0F 81 cd"},
	{"JNP", 1, {"moffs16"}, "d", "o16 0F 8B cw"},
	{"JNP", 1, {"moffs32"}, "d", "o32 0F 8B cd"},
	{"JNS", 1, {"moffs16"}, "d", "o16 0F 89 cw"},
	{"JNS", 1, {"moffs32"}, "d", "o32 0F 89 cd"},
	{"JNZ", 1, {"moffs16"}, "d", "o16 0F 85 cw"},
	{"JNZ", 1, {"moffs32"}, "d", "o32 0F 85 cd"},
	{"JO", 1, {"moffs16"}, "d", "o16 0F 80 cw"},
	{"JO", 1, {"moffs32"}, "d", "o32 0F 80 cd"},
	{"JP", 1, {"moffs16"}, "d", "o16 0F 8A cw"},
	{"JP", 1, {"moffs32"}, "d", "o32 0F 8A cd"},
	{"JPE", 1, {"moffs16"}, "d", "o16 0F 8A cw"},
	{"JPE", 1, {"moffs32"}, "d", "o32 0F 8A cd"},
	{"JPO", 1, {"moffs16"}, "d", "o16 0F 8B cw"},
	{"JPO", 1, {"moffs32"}, "d", "o32 0F 8B cd"},
	{"JS", 1, {"moffs16"}, "d", "o16 0F 88 cw"},
	{"JS", 1, {"moffs32"}, "d", "o32 0F 88 cd"},
	{"JZ", 1, {"moffs16"}, "d", "o16 0F 84 cw"},
	{"JZ", 1, {"moffs32"}, "d", "o32 0F 84 cd"},
	
	{"JMPN", 1, {"moffs8"}, "d", "EB cb"},
	{"JMPN", 1, {"moffs16"}, "d", "o16 E9 cw"},
	{"JMPN", 1, {"moffs32"}, "d", "o32 E9 cd"},
	
	{"JMP", 1, {"rm16"}, "m", "o16 FF /4"},
	{"JMP", 1, {"rm32"}, "m", "o32 FF /4"},
	{"JMP", 1, {"rm64"}, "m", "o64 FF /4"},
	
	{"JMPF", 1, {"ptr16:16"}, "d", "o16 EA cd"},
	{"JMPF", 1, {"ptr16:32"}, "d", "o32 EA cp"},
	{"JMPF", 1, {"m16:16"}, "m", "o16 FF /5"},
	{"JMPF", 1, {"m16:32"}, "m", "o32 FF /5"},
	{"JMPF", 1, {"m16:64"}, "m", "rxW FF /5"},
	
	{"LAHF", 0, {}, "", "9F"},
	{"LAR", 2, {"r16","rm16"}, "rm", "o16 0F 02 /r"},
	
	--LDDQU, LDMXCSR
	
	{"LDS", 2, {"r16","m16:16"}, "rm", "o16 C5 /r"},
	{"LDS", 2, {"r32","m16:32"}, "rm", "o32 C5 /r"},
	{"LSS", 2, {"r16","m16:16"}, "rm", "o16 0F B2 /r"},
	{"LSS", 2, {"r32","m16:32"}, "rm", "o32 0F B2 /r"},
	{"LSS", 2, {"r64","m16:64"}, "rm", "rxW 0F B2 /r"},
	{"LES", 2, {"r16","m16:16"}, "rm", "o16 C4 /r"},
	{"LES", 2, {"r32","m16:32"}, "rm", "o32 C4 /r"},
	{"LFS", 2, {"r16","m16:16"}, "rm", "o16 0F B4 /r"},
	{"LFS", 2, {"r32","m16:32"}, "rm", "o32 0F B4 /r"},
	{"LFS", 2, {"r64","m16:64"}, "rm", "rxW 0F B4 /r"},
	{"LGS", 2, {"r16","m16:16"}, "rm", "o16 0F B5 /r"},
	{"LGS", 2, {"r32","m16:32"}, "rm", "o32 0F B5 /r"},
	{"LGS", 2, {"r64","m16:64"}, "rm", "rxW 0F B5 /r"},
	
	{"LEA", 2, {"r16","m"}, "rm", "o16 8D /r"},
	{"LEA", 2, {"r32","m"}, "rm", "o32 8D /r"},
	{"LEA", 2, {"r64","m"}, "rm", "rxW 8D /r"},
	
	{"LEAVE", 0, {}, "", "o16 C9"},
	{"LEAVE", 0, {}, "", "o32 C9"},
	{"LEAVE", 0, {}, "", "rxW C9"},
	
	{"LFENCE", 0, {}, "", "0F AE /5"},
	
	{"LGDT", 1, {"m16&32"}, "m", "0F 01 /2"},
	{"LGDT", 1, {"m16&64"}, "m", "rxW 0F 01 /2"},
	{"LIDT", 1, {"m16&32"}, "m", "0F 01 /3"},
	{"LIDT", 1, {"m16&64"}, "m", "rxW 0F 01 /3"},
	{"LLDT", 1, {"rm16"}, "m", "0F 00 /2"},
	{"LMSW", 1, {"rm16"}, "m", "0F 01 /6"},
	
	{"LODSB", 0, {}, "", "AC"},
	{"LODSW", 0, {}, "", "o16 AD"},
	{"LODSD", 0, {}, "", "o32 AD"},
	{"LODSQ", 0, {}, "", "rxW AD"},
	
	{"LOOP", 1, {"rel8"}, "d", "E2 cb"},
	{"LOOPE", 1, {"rel8"}, "d", "E1 cb"},
	{"LOOPNE", 1, {"rel8"}, "d", "E0 cb"},
	
	--LSL
	
	{"LTR", 1, {"rm16"}, "m", "0F 00 /3"},
	
	-- MASKMOVDQU - MAXSS
	
	{"MFENCE", 0, {}, "", "0F AE /6"},
	
	-- MINPD - MINSS
	
	{"MONITOR", 0, {}, "", "0F 01 C8"},

	{"MOV", 2, {"rm8","r8"}, "mr", "88 /r"},
	{"MOV", 2, {"rm16","r16"}, "mr", "o16 89 /r"},
	{"MOV", 2, {"rm32","r32"}, "mr", "o32 89 /r"},
	{"MOV", 2, {"rm64","r64"}, "mr", "rxW 89 /r"},
	{"MOV", 2, {"r8","rm8"}, "rm", "8A /r"},
	{"MOV", 2, {"r16","rm16"}, "rm", "o16 8B /r"},
	{"MOV", 2, {"r32","rm32"}, "rm", "o32 8B /r"},
	{"MOV", 2, {"r64","rm64"}, "rm", "rxW 8B /r"},
	{"MOV", 2, {"rm16","Sreg"}, "mr", "8C /r"},
	{"MOV", 2, {"rm64","Sreg"}, "mr", "rxW 8C /r"},
	{"MOV", 2, {"Sreg","rm16"}, "rm", "8E /r"},
	{"MOV", 2, {"Sreg","rm64"}, "rm", "rxW 8E /r"},
	{"MOV", 2, {"AL","moffs8"}, "-d", "A0 db"},
	{"MOV", 2, {"AX","moffs16"}, "-d", "o16 A1 dw"},
	{"MOV", 2, {"EAX","moffs32"}, "-d", "o32 A1 dd"},
	{"MOV", 2, {"RAX","moffs64"}, "-d", "rxW A1 dq"},
	{"MOV", 2, {"moffs8","AL"}, "d-", "A2 db"},
	{"MOV", 2, {"moffs16","AX"}, "d-", "o16 A3 dw"},
	{"MOV", 2, {"moffs32","EAX"}, "d-", "o32 A3 dd"},
	{"MOV", 2, {"moffs64","RAX"}, "d-", "rxW A3 dq"},
	{"MOV", 2, {"r8","imm8"}, "ri", "B0 rb ib"},
	{"MOV", 2, {"r16","imm16"}, "ri", "o16 B8 rw iw"},
	{"MOV", 2, {"r32","imm32"}, "ri", "o32 B8 rd id"},
	{"MOV", 2, {"r64","imm64"}, "ri", "rxW B8 rq iq"},
	{"MOV", 2, {"rm8","imm8"}, "ri", "C6 /0 ib"},
	{"MOV", 2, {"rm16","imm16"}, "ri", "o16 C7 /0 iw"},
	{"MOV", 2, {"rm32","imm32"}, "ri", "o32 C7 /0 id"},
	{"MOV", 2, {"rm64","imm64"}, "ri", "rxW C7 /0 iq"},
	
	{"MOV", 2, {"r32","Creg"}, "mr", "0F 20 /r"},
	{"MOV", 2, {"r64","Creg"}, "mr", "rxW 0F 20 /r"},
	{"MOV", 2, {"Creg","r32"}, "rm", "0F 22 /r"},
	{"MOV", 2, {"Creg","r64"}, "rm", "rxW 0F 22 /r"},
	
	{"MOV", 2, {"r32","Dreg"}, "mr", "0F 21 /r"},
	{"MOV", 2, {"r64","Dreg"}, "mr", "rxW 0F 21 /r"},
	{"MOV", 2, {"Dreg","r32"}, "rm", "0F 23 /r"},
	{"MOV", 2, {"Dreg","r64"}, "rm", "rxW 0F 23 /r"},
	
	-- MOVAPD, MOVAPS
	
	{"MOVBE", 2, {"r16","m16"}, "rm", "o16 0F 38 F0 /r"},
	{"MOVBE", 2, {"r32","m32"}, "rm", "o32 0F 38 F0 /r"},
	{"MOVBE", 2, {"r64","m64"}, "rm", "rxW 0F 38 F0 /r"},
	{"MOVBE", 2, {"m16","r16"}, "mr", "o16 0F 38 F1 /r"},
	{"MOVBE", 2, {"m32","r32"}, "mr", "o32 0F 38 F1 /r"},
	{"MOVBE", 2, {"m64","r64"}, "mr", "rxW 0F 38 F1 /r"},
	
	-- MOVD/MOVQ - MOVSS
	
	{"MOVSB", 0, {}, "", "A4"},
	{"MOVSW", 0, {}, "", "o16 A5"},
	{"MOVSD", 0, {}, "", "o32 A5"},
	{"MOVSQ", 0, {}, "", "rxW A5"},
	
	-- MOVUPD, MOVUPS
	
	{"MOVZX", 2, {"r16","rm8"}, "rm", "o16 0F B6 /r"},
	{"MOVZX", 2, {"r32","rm8"}, "rm", "o32 0F B6 /r"},
	{"MOVZX", 2, {"r64","rm8"}, "rm", "rxW 0F B6 /r"},
	{"MOVZX", 2, {"r32","rm16"}, "rm", "0F B7 /r"},
	{"MOVZX", 2, {"r64","rm64"}, "rm", "rxW B7 /r"},
	
	-- MPSADBW
	
	{"MUL", 1, {"rm8"}, "m", "F6 /4"},
	{"MUL", 1, {"rm16"}, "m", "o16 F7 /4"},
	{"MUL", 1, {"rm32"}, "m", "o32 F7 /4"},
	{"MUL", 1, {"rm64"}, "m", "rxW F7 /4"},
	
	-- MULPD - MULSS
	
	{"MWAIT", 0, {}, "", "0F 01 C9"},
	
	{"NEG", 1, {"rm8"}, "m", "F6 /3"},
	{"NEG", 1, {"rm16"}, "m", "o16 F7 /3"},
	{"NEG", 1, {"rm32"}, "m", "o32 F7 /3"},
	{"NEG", 1, {"rm64"}, "m", "rxW F7 /3"},
	
	{"NOP", 0, {}, "", "90"},
	{"NOP", 1, {"rm16"}, "m", "o16 0F 1F /0"},
	{"NOP", 1, {"rm32"}, "m", "o32 0F 1F /0"},
	
	{"NOT", 1, {"rm8"}, "m", "F6 /2"},
	{"NOT", 1, {"rm16"}, "m", "o16 F7 /2"},
	{"NOT", 1, {"rm32"}, "m", "o32 F7 /2"},
	{"NOT", 1, {"rm64"}, "m", "rxW F7 /2"},
	
	{"OR", 2, {"AL","imm8"}, "-i", "0C ib"},
	{"OR", 2, {"AX","imm16"}, "-i", "o16 0D iw"},
	{"OR", 2, {"EAX","imm32"}, "-i", "o32 0D id"},
	{"OR", 2, {"RAX","imm32"}, "-i", "rxW 0D iq"},
	{"OR", 2, {"rm8","imm8"}, "mi", "80 /1 ib"},
	{"OR", 2, {"rm16","imm16"}, "mi", "o16 81 /1 iw"},
	{"OR", 2, {"rm32","imm32"}, "mi", "o32 81 /1 id"},
	{"OR", 2, {"rm64","imm32"}, "mi", "rxW 81 /1 iq"},
	{"OR", 2, {"rm16","imm8"}, "mi", "o16 83 /1 ib"},
	{"OR", 2, {"rm32","imm8"}, "mi", "o32 83 /1 ib"},
	{"OR", 2, {"rm64","imm8"}, "mi", "rxW 83 /1 ib"},
	{"OR", 2, {"rm8","r8"}, "mr", "08 /r"},
	{"OR", 2, {"rm16","r16"}, "mr", "o16 08 /r"},
	{"OR", 2, {"rm32","r32"}, "mr", "o32 09 /r"},
	{"OR", 2, {"rm64","r64"}, "mr", "rxW 09 /r"},
	{"OR", 2, {"r8","rm8"}, "rm", "0A /r"},
	{"OR", 2, {"r16","rm16"}, "rm", "o16 0B /r"},
	{"OR", 2, {"r32","rm32"}, "rm", "o32 0B /r"},
	{"OR", 2, {"r64","rm64"}, "rm", "rxW 0B /r"},
	
	-- ORPD, ORPS
	
	{"OUT", 2, {"imm8","AL"}, "i-", "E6 ib"},
	{"OUT", 2, {"imm8","AX"}, "i-", "o16 E7 ib"},
	{"OUT", 2, {"imm8","EAX"}, "i-", "o32 E7 ib"},
	{"OUT", 2, {"DX","AL"}, "--", "EE"},
	{"OUT", 2, {"DX","AX"}, "--", "o16 EF"},
	{"OUT", 2, {"DX","EAX"}, "--", "o32 EF"},
	
	{"OUTSB", 0, {}, "", "6E"},
	{"OUTSW", 0, {}, "", "o16 6F"},
	{"OUTSD", 0, {}, "", "o32 6F"},
	
	--PABSB - PANDN
	
	{"PAUSE", 0, {}, "", "F3 90"},
	
	--PAVGB - PMULUDQ
	
	{"POP", 1, {"rm16"}, "m", "o16 8F /0"},
	{"POP", 1, {"rm32"}, "m", "o32 8F /0"},
	{"POP", 1, {"rm64"}, "m", "rxW 8F /0"},
	{"POP", 1, {"r16"}, "r", "o16 58 rw"},
	{"POP", 1, {"r32"}, "r", "o32 58 rd"},
	{"POP", 1, {"r64"}, "r", "rxW 58 rq"},
	{"POP", 1, {"DS"}, "-", "1F"},
	{"POP", 1, {"ES"}, "-", "07"},
	{"POP", 1, {"SS"}, "-", "17"},
	{"POP", 1, {"FS"}, "-", "o16 0F A1"},
	{"POP", 1, {"FS"}, "-", "o32 0F A1"},
	{"POP", 1, {"FS"}, "-", "rxW 0F A1"},
	{"POP", 1, {"GS"}, "-", "o16 0F A9"},
	{"POP", 1, {"GS"}, "-", "o32 0F A9"},
	{"POP", 1, {"GS"}, "-", "rxW 0F A9"},
	
	{"POPA", 0, {}, "", "o16 61"},
	{"POPAD", 0, {}, "", "o32 61"},
	
	{"POPCNT", 2, {"r16","rm16"}, "rm", "o16 F3 0F B8 /r"},
	{"POPCNT", 2, {"r32","rm32"}, "rm", "o32 F3 0F B8 /r"},
	{"POPCNT", 2, {"r64","rm64"}, "rm", "rxW F3 0F B8 /r"},
	
	{"POPF", 0, {}, "", "o16 9D"},
	{"POPFD", 0, {}, "", "o32 9D"},
	{"POPFQ", 0, {}, "", "rxW 9D"},
	
	-- POR
	
	{"PREFETCH0", 1, {"m8"}, "m", "0F 18 /1"},
	{"PREFETCH1", 1, {"m8"}, "m", "0F 18 /2"},
	{"PREFETCH2", 1, {"m8"}, "m", "0F 18 /3"},
	{"PREFETCHNTA", 1, {"m8"}, "m", "0F 18 /0"},
	
	-- PSADBW - PUNPCKLBW
	
	{"PUSH", 1, {"rm16"}, "m", "o16 FF /6"},
	{"PUSH", 1, {"rm32"}, "m", "o32 FF /6"},
	{"PUSH", 1, {"rm64"}, "m", "rxW FF /6"},
	{"PUSH", 1, {"r16"}, "r", "o16 50 rw"},
	{"PUSH", 1, {"r32"}, "r", "o32 50 rd"},
	{"PUSH", 1, {"r64"}, "r", "rxW 50 rq"},
	{"PUSH", 1, {"imm8"}, "i", "6A ib"},
	{"PUSH", 1, {"imm16"}, "i", "o16 68 iw"},
	{"PUSH", 1, {"imm32"}, "i", "o32 68 id"},
	{"PUSH", 1, {"CS"}, "-", "0E"},
	{"PUSH", 1, {"SS"}, "-", "16"},
	{"PUSH", 1, {"DS"}, "-", "1E"},
	{"PUSH", 1, {"ES"}, "-", "06"},
	{"PUSH", 1, {"FS"}, "-", "0F A0"},
	{"PUSH", 1, {"GS"}, "-", "0F A8"},
	
	{"PUSHA", 0, {}, "", "o16 60"},
	{"PUSHAD", 0, {}, "", "o32 60"},
	
	{"PUSHF", 0, {}, "", "o16 9C"},
	{"PUSHFD", 0, {}, "", "o32 9C"},
	{"PUSHFQ", 0, {}, "", "rxW 9C"},
	
	-- PXOR
	
	{"RCL", 2, {"rm8","1"}, "m-", "D0 /2"},
	{"RCL", 2, {"rm8","CL"}, "m-", "D2 /2"},
	{"RCL", 2, {"rm8","imm8"}, "mi", "C0 /2 ib"},
	{"RCL", 2, {"rm16","1"}, "m-", "o16 D1 /2"},
	{"RCL", 2, {"rm16","CL"}, "m-", "o16 D3 /2"},
	{"RCL", 2, {"rm16","imm8"}, "mi", "o16 C1 /2 ib"},
	{"RCL", 2, {"rm32","1"}, "m-", "o32 D1 /2"},
	{"RCL", 2, {"rm64","1"}, "m-", "rxW D1 /2"},
	{"RCL", 2, {"rm32","CL"}, "m-", "o32 D3 /2"},
	{"RCL", 2, {"rm64","CL"}, "m-", "rxW D3 /2"},
	{"RCL", 2, {"rm32","imm8"}, "mi", "o32 C1 /2 ib"},
	{"RCL", 2, {"rm64","imm8"}, "mi", "rxW C1 /2 ib"},
	
	{"RCR", 2, {"rm8","1"}, "m-", "D0 /3"},
	{"RCR", 2, {"rm8","CL"}, "m-", "D2 /3"},
	{"RCR", 2, {"rm8","imm8"}, "mi", "C0 /3 ib"},
	{"RCR", 2, {"rm16","1"}, "m-", "o16 D1 /3"},
	{"RCR", 2, {"rm16","CL"}, "m-", "o16 D3 /3"},
	{"RCR", 2, {"rm16","imm8"}, "mi", "o16 C1 /3 ib"},
	{"RCR", 2, {"rm32","1"}, "m-", "o32 D1 /3"},
	{"RCR", 2, {"rm64","1"}, "m-", "rxW D1 /3"},
	{"RCR", 2, {"rm32","CL"}, "m-", "o32 D3 /3"},
	{"RCR", 2, {"rm64","CL"}, "m-", "rxW D3 /3"},
	{"RCR", 2, {"rm32","imm8"}, "mi", "o32 C1 /3 ib"},
	{"RCR", 2, {"rm64","imm8"}, "mi", "rxW C1 /3 ib"},
	
	{"ROL", 2, {"rm8","1"}, "m-", "D0 /0"},
	{"ROL", 2, {"rm8","CL"}, "m-", "D2 /0"},
	{"ROL", 2, {"rm8","imm8"}, "mi", "C0 /0 ib"},
	{"ROL", 2, {"rm16","1"}, "m-", "o16 D1 /0"},
	{"ROL", 2, {"rm16","CL"}, "m-", "o16 D3 /0"},
	{"ROL", 2, {"rm16","imm8"}, "mi", "o16 C1 /0 ib"},
	{"ROL", 2, {"rm32","1"}, "m-", "o32 D1 /0"},
	{"ROL", 2, {"rm64","1"}, "m-", "rxW D1 /0"},
	{"ROL", 2, {"rm32","CL"}, "m-", "o32 D3 /0"},
	{"ROL", 2, {"rm64","CL"}, "m-", "rxW D3 /0"},
	{"ROL", 2, {"rm32","imm8"}, "mi", "o32 C1 /0 ib"},
	{"ROL", 2, {"rm64","imm8"}, "mi", "rxW C1 /0 ib"},
	
	{"ROR", 2, {"rm8","1"}, "m-", "D0 /1"},
	{"ROR", 2, {"rm8","CL"}, "m-", "D2 /1"},
	{"ROR", 2, {"rm8","imm8"}, "mi", "C0 /1 ib"},
	{"ROR", 2, {"rm16","1"}, "m-", "o16 D1 /1"},
	{"ROR", 2, {"rm16","CL"}, "m-", "o16 D3 /1"},
	{"ROR", 2, {"rm16","imm8"}, "mi", "o16 C1 /1 ib"},
	{"ROR", 2, {"rm32","1"}, "m-", "o32 D1 /1"},
	{"ROR", 2, {"rm64","1"}, "m-", "rxW D1 /1"},
	{"ROR", 2, {"rm32","CL"}, "m-", "o32 D3 /1"},
	{"ROR", 2, {"rm64","CL"}, "m-", "rxW D3 /1"},
	{"ROR", 2, {"rm32","imm8"}, "mi", "o32 C1 /1 ib"},
	{"ROR", 2, {"rm64","imm8"}, "mi", "rxW C1 /1 ib"},
	
	-- RCPPS - RDFSBASE
	
	{"RDMSR", 0, {}, "", "0F 32"},
	{"RDPMC", 0, {}, "", "0F 33"},
	
	{"RDRAND", 1, {"r16"}, "r", "o16 0F C7 /6"},
	{"RDRAND", 1, {"r32"}, "r", "o32 0F C7 /6"},
	{"RDRAND", 1, {"r64"}, "r", "rxW 0F C7 /6"},
	
	{"RDTSC", 0, {}, "", "0F 31"},
	{"RDTSCP", 0, {}, "", "0F 01 F9"},
	
	{"RET", 0, {}, "", "C3"},
	{"RETN", 0, {}, "", "C3"},
	{"RETF", 0, {}, "", "CB"},
	{"RET", 1, {"imm16"}, "i", "C8 iw"},
	{"RETN", 1, {"imm16"}, "i", "C8 iw"},
	{"RETF", 1, {"imm16"}, "i", "CA iw"},
	
	-- ROUNDPD - ROUNDSS
	
	{"RSM", 0, {}, "", "0F AA"},
	
	-- RSQRTPS - RSQRTSS
	
	{"SAHF", 0, {}, "", "9E"},
	
	{"SAL", 2, {"rm8","1"}, "m-", "D0 /4"},
	{"SAL", 2, {"rm8","CL"}, "m-", "D2 /4"},
	{"SAL", 2, {"rm8","imm8"}, "mi", "C0 /4 ib"},
	{"SAL", 2, {"rm16","1"}, "m-", "o16 D1 /4"},
	{"SAL", 2, {"rm16","CL"}, "m-", "o16 D3 /4"},
	{"SAL", 2, {"rm16","imm8"}, "mi", "o16 C1 /4 ib"},
	{"SAL", 2, {"rm32","1"}, "m-", "o32 D1 /4"},
	{"SAL", 2, {"rm64","1"}, "m-", "rxW D1 /4"},
	{"SAL", 2, {"rm32","CL"}, "m-", "o32 D3 /4"},
	{"SAL", 2, {"rm64","CL"}, "m-", "rxW D3 /4"},
	{"SAL", 2, {"rm32","imm8"}, "mi", "o32 C1 /4 ib"},
	{"SAL", 2, {"rm64","imm8"}, "mi", "rxW C1 /4 ib"},
	
	{"SAR", 2, {"rm8","1"}, "m-", "D0 /7"},
	{"SAR", 2, {"rm8","CL"}, "m-", "D2 /7"},
	{"SAR", 2, {"rm8","imm8"}, "mi", "C0 /7 ib"},
	{"SAR", 2, {"rm16","1"}, "m-", "o16 D1 /7"},
	{"SAR", 2, {"rm16","CL"}, "m-", "o16 D3 /7"},
	{"SAR", 2, {"rm16","imm8"}, "mi", "o16 C1 /7 ib"},
	{"SAR", 2, {"rm32","1"}, "m-", "o32 D1 /7"},
	{"SAR", 2, {"rm64","1"}, "m-", "rxW D1 /7"},
	{"SAR", 2, {"rm32","CL"}, "m-", "o32 D3 /7"},
	{"SAR", 2, {"rm64","CL"}, "m-", "rxW D3 /7"},
	{"SAR", 2, {"rm32","imm8"}, "mi", "o32 C1 /7 ib"},
	{"SAR", 2, {"rm64","imm8"}, "mi", "rxW C1 /7 ib"},
	
	{"SHL", 2, {"rm8","1"}, "m-", "D0 /4"},
	{"SHL", 2, {"rm8","CL"}, "m-", "D2 /4"},
	{"SHL", 2, {"rm8","imm8"}, "mi", "C0 /4 ib"},
	{"SHL", 2, {"rm16","1"}, "m-", "o16 D1 /4"},
	{"SHL", 2, {"rm16","CL"}, "m-", "o16 D3 /4"},
	{"SHL", 2, {"rm16","imm8"}, "mi", "o16 C1 /4 ib"},
	{"SHL", 2, {"rm32","1"}, "m-", "o32 D1 /4"},
	{"SHL", 2, {"rm64","1"}, "m-", "rxW D1 /4"},
	{"SHL", 2, {"rm32","CL"}, "m-", "o32 D3 /4"},
	{"SHL", 2, {"rm64","CL"}, "m-", "rxW D3 /4"},
	{"SHL", 2, {"rm32","imm8"}, "mi", "o32 C1 /4 ib"},
	{"SHL", 2, {"rm64","imm8"}, "mi", "rxW C1 /4 ib"},
	
	{"SHR", 2, {"rm8","1"}, "m-", "D0 /5"},
	{"SHR", 2, {"rm8","CL"}, "m-", "D2 /5"},
	{"SHR", 2, {"rm8","imm8"}, "mi", "C0 /5 ib"},
	{"SHR", 2, {"rm16","1"}, "m-", "o16 D1 /5"},
	{"SHR", 2, {"rm16","CL"}, "m-", "o16 D3 /5"},
	{"SHR", 2, {"rm16","imm8"}, "mi", "o16 C1 /5 ib"},
	{"SHR", 2, {"rm32","1"}, "m-", "o32 D1 /5"},
	{"SHR", 2, {"rm64","1"}, "m-", "rxW D1 /5"},
	{"SHR", 2, {"rm32","CL"}, "m-", "o32 D3 /5"},
	{"SHR", 2, {"rm64","CL"}, "m-", "rxW D3 /5"},
	{"SHR", 2, {"rm32","imm8"}, "mi", "o32 C1 /5 ib"},
	{"SHR", 2, {"rm64","imm8"}, "mi", "rxW C1 /5 ib"},
	
	{"SBB", 2, {"AL","imm8"}, "-i", "1C ib"},
	{"SBB", 2, {"AX","imm16"}, "-i", "o16 1D iw"},
	{"SBB", 2, {"EAX","imm32"}, "-i", "o32 ID id"},
	{"SBB", 2, {"RAX","imm32"}, "-i", "rxW ID id"},
	{"SBB", 2, {"rm8","imm8"}, "mi", "80 /3 ib"},
	{"SBB", 2, {"rm16","imm16"}, "mi", "o16 81 /3 iw"},
	{"SBB", 2, {"rm32","imm32"}, "mi", "o32 81 /3 id"},
	{"SBB", 2, {"rm64","imm32"}, "mi", "rxW 81 /3 id"},
	{"SBB", 2, {"rm16","imm8"}, "mi", "o16 83 /3 ib"},
	{"SBB", 2, {"rm32","imm8"}, "mi", "o32 83 /3 ib"},
	{"SBB", 2, {"rm64","imm8"}, "mi", "rxW 83 /3 ib"},
	{"SBB", 2, {"rm8","r8"}, "mr", "18 /r"},
	{"SBB", 2, {"rm16","r16"}, "mr", "o16 19 /r"},
	{"SBB", 2, {"rm32","r32"}, "mr", "o32 19 /r"},
	{"SBB", 2, {"rm64","r64"}, "mr", "rxW 19 /r"},
	{"SBB", 2, {"r8","rm8"}, "rm", "1A /r"},
	{"SBB", 2, {"r16","rm16"}, "rm", "o16 1B /r"},
	{"SBB", 2, {"r32","rm32"}, "rm", "o32 1B /r"},
	{"SBB", 2, {"r64","rm64"}, "rm", "rxW 1B /r"},
	
	{"SCASB", 0, {}, "", "AE"},
	{"SCASW", 0, {}, "", "o16 AF"},
	{"SCASD", 0, {}, "", "o32 AF"},
	{"SCASQ", 0, {}, "", "rxW AF"},
	
	{"SETA", 1, {"rm8"}, "m", "0F 97 /r"},
	{"SETAE", 1, {"rm8"}, "m", "0F 93 /r"},
	{"SETB", 1, {"rm8"}, "m", "0F 92 /r"},
	{"SETBE", 1, {"rm8"}, "m", "0F 96 /r"},
	{"SETC", 1, {"rm8"}, "m", "0F 92 /r"},
	{"SETE", 1, {"rm8"}, "m", "0F 94 /r"},
	{"SETG", 1, {"rm8"}, "m", "0F 9F /r"},
	{"SETGE", 1, {"rm8"}, "m", "0F 9D /r"},
	{"SETL", 1, {"rm8"}, "m", "0F 9C /r"},
	{"SETLE", 1, {"rm8"}, "m", "0F 9E /r"},
	{"SETNA", 1, {"rm8"}, "m", "0F 96 /r"},
	{"SETNAE", 1, {"rm8"}, "m", "0F 92 /r"},
	{"SETNB", 1, {"rm8"}, "m", "0F 93 /r"},
	{"SETNBE", 1, {"rm8"}, "m", "0F 97 /r"},
	{"SETNC", 1, {"rm8"}, "m", "0F 93 /r"},
	{"SETNE", 1, {"rm8"}, "m", "0F 95 /r"},
	{"SETNG", 1, {"rm8"}, "m", "0F 9E /r"},
	{"SETNGE", 1, {"rm8"}, "m", "0F 9C /r"},
	{"SETNL", 1, {"rm8"}, "m", "0F 9D /r"},
	{"SETNLE", 1, {"rm8"}, "m", "0F 9F /r"},
	{"SETNO", 1, {"rm8"}, "m", "0F 91 /r"},
	{"SETNP", 1, {"rm8"}, "m", "0F 9B /r"},
	{"SETNS", 1, {"rm8"}, "m", "0F 99 /r"},
	{"SETNZ", 1, {"rm8"}, "m", "0F 95 /r"},
	{"SETO", 1, {"rm8"}, "m", "0F 90 /r"},
	{"SETP", 1, {"rm8"}, "m", "0F 9A /r"},
	{"SETPE", 1, {"rm8"}, "m", "0F 9A /r"},
	{"SETPO", 1, {"rm8"}, "m", "0F 9B /r"},
	{"SETS", 1, {"rm8"}, "m", "0F 98 /r"},
	{"SETZ", 1, {"rm8"}, "m", "0F 94 /r"},
	
	{"SFENCE", 0, {}, "", "0F AE /7"},
	{"SGDT", 1, {"m"}, "m", "0F 01 /0"},
	
	{"SHLD", 3, {"rm16","r16","imm8"}, "mri", "o16 0F A4 /r ib"},
	{"SHLD", 3, {"rm16","r16","CL"}, "mr-", "o16 0F A5 /r"},
	{"SHLD", 3, {"rm32","r32","imm8"}, "mri", "o32 0F A4 /r ib"},
	{"SHLD", 3, {"rm64","r64","imm8"}, "mri", "rxW 0F A4 /r ib"},
	{"SHLD", 3, {"rm32","r32","CL"}, "mr-", "o32 0F A5 /r"},
	{"SHLD", 3, {"rm64","r64","CL"}, "mr-", "rxW 0F A5 /r"},
	
	{"SHRD", 3, {"rm16","r16","imm8"}, "mri", "o16 0F AC /r ib"},
	{"SHRD", 3, {"rm16","r16","CL"}, "mr-", "o16 0F AD /r"},
	{"SHRD", 3, {"rm32","r32","imm8"}, "mri", "o32 0F AC /r ib"},
	{"SHRD", 3, {"rm64","r64","imm8"}, "mri", "rxW 0F AC /r ib"},
	{"SHRD", 3, {"rm32","r32","CL"}, "mr-", "o32 0F AD /r"},
	{"SHRD", 3, {"rm64","r64","CL"}, "mr-", "rxW 0F AD /r"},
	
	-- SHUFPD, SHUFPS
	
	{"SIDT", 1, {"m"}, "m", "0F 01 /1"},
	
	{"SLDT", 1, {"rm16"}, "m", "0F 00 /0"},
	{"SLDT", 1, {"r64"}, "m", "rxW 0F 00 /0"},
	
	{"SMSW", 1, {"rm16"}, "m", "o16 0F 01 /4"},
	{"SMSW", 1, {"r32"}, "m", "o32 0F 01 /4"},
	{"SMSW", 1, {"r64"}, "m", "rxW 0F 01 /4"},
	
	-- SQRTPD - SQRTSD
	
	{"STC", 0, {}, "", "F9"},
	{"STD", 0, {}, "", "FD"},
	{"STI", 0, {}, "", "FB"},
	
	-- STMXCSR
	
	{"STOSB", 0, {}, "", "AA"},
	{"STOSW", 0, {}, "", "o16 AB"},
	{"STOSD", 0, {}, "", "o32 AB"},
	{"STOSQ", 0, {}, "", "rxW AB"},
	
	{"STR", 1, {"rm16"}, "m", "0F 00 /1"},
	
	{"SUB", 2, {"AL","imm8"}, "-i", "2C ib"},
	{"SUB", 2, {"AX","imm16"}, "-i", "o16 2D iw"},
	{"SUB", 2, {"EAX","imm32"}, "-i", "o32 2D id"},
	{"SUB", 2, {"RAX","imm32"}, "-i", "rxW 2D id"},
	{"SUB", 2, {"rm8","imm8"}, "mi", "80 /5 ib"},
	{"SUB", 2, {"rm16","imm16"}, "mi", "o16 81 /5 iw"},
	{"SUB", 2, {"rm32","imm32"}, "mi", "o32 81 /5 id"},
	{"SUB", 2, {"rm64","imm32"}, "mi", "rxW 81 /5 id"},
	{"SUB", 2, {"rm16","imm8"}, "mi", "o16 83 /5 ib"},
	{"SUB", 2, {"rm32","imm8"}, "mi", "o32 83 /5 ib"},
	{"SUB", 2, {"rm64","imm8"}, "mi", "rxW 83 /5 ib"},
	{"SUB", 2, {"rm8","r8"}, "mr", "28 /r"},
	{"SUB", 2, {"rm16","r16"}, "mr", "o16 29 /r"},
	{"SUB", 2, {"rm32","r32"}, "mr", "o32 29 /r"},
	{"SUB", 2, {"rm64","r64"}, "mr", "rxW 29 /r"},
	{"SUB", 2, {"r8","rm8"}, "rm", "2A /r"},
	{"SUB", 2, {"r16","rm16"}, "rm", "o16 2B /r"},
	{"SUB", 2, {"r32","rm32"}, "rm", "o32 2B /r"},
	{"SUB", 2, {"r64","rm64"}, "rm", "rxW 2B /r"},
	
	-- SUBPD - SUBSS
	
	{"SWAPGS", 0, {}, "", "0F 01 /7"},
	
	{"SYSCALL", 0, {}, "", "0F 05"},
	{"SYSENTER", 0, {}, "", "0F 34"},
	{"SYSEXIT", 0, {}, "", "0F 35"},
	{"SYSRET", 0, {}, "", "0F 07"},
	
	{"TEST", 2, {"AL","imm8"}, "-i", "A8 ib"},
	{"TEST", 2, {"AX","imm16"}, "-i", "o16 A9 iw"},
	{"TEST", 2, {"EAX","imm32"}, "-i", "o32 A9 id"},
	{"TEST", 2, {"RAX","imm32"}, "-i", "rxW A9 id"},
	{"TEST", 2, {"rm8","imm8"}, "mi", "F6 /0 ib"},
	{"TEST", 2, {"rm16","imm16"}, "mi", "o16 F7 /0 iw"},
	{"TEST", 2, {"rm32","imm32"}, "mi", "o32 F7 /0 id"},
	{"TEST", 2, {"rm64","imm32"}, "mi", "rxW F7 /0 id"},
	{"TEST", 2, {"rm8","r8"}, "mr", "84 /r"},
	{"TEST", 2, {"rm16","r16"}, "mr", "o16 85 /r"},
	{"TEST", 2, {"rm32","r32"}, "mr", "o32 85 /r"},
	{"TEST", 2, {"rm64","r64"}, "mr", "rxW 85 /r"},
	
	-- UCOMISD, UCOMISS
	
	{"UD2", 0, {}, "", "0F 0B"},
	
	-- UNPCKHPD - VCVTPS2PH
	
	{"VERR", 1, {"rm16"}, "m", "0F 00 /4"},
	{"VERW", 1, {"rm16"}, "m", "0F 00 /5"},
	
	-- VEXTRACTF128 - VZEROUPPER
	
	{"WAIT", 0, {}, "", "9B"},
	{"FWAIT", 0, {}, "", "9B"},
	
	{"WBINVD", 0, {}, "", "0F 09"},
	
	{"WRFSBASE", 1, {"r32"}, "m", "F3 0F AE /2"},
	{"WRFSBASE", 1, {"r64"}, "m", "rxW F3 0F AE /2"},
	{"WRGSBASE", 1, {"r32"}, "m", "F3 0F AE /3"},
	{"WRGSBASE", 1, {"r64"}, "m", "rxW F3 0F AE /3"},
	
	{"WRMSR", 0, {}, "", "0F 30"},
	
	{"XADD", 2, {"rm8","r8"}, "mr", "0F C0 /r"},
	{"XADD", 2, {"rm16","r16"}, "mr", "o16 0F C1 /r"},
	{"XADD", 2, {"rm32","r32"}, "mr", "o32 0F C1 /r"},
	{"XADD", 2, {"rm64","r64"}, "mr", "rxW 0F C1 /r"},
	
	{"XCHG", 2, {"AX","r16"}, "-r", "o16 90 rw"},
	{"XCHG", 2, {"r16","AX"}, "r-", "o16 90 rw"},
	{"XCHG", 2, {"EAX","r32"}, "-r", "o32 90 rd"},
	{"XCHG", 2, {"RAX","r64"}, "-r", "rxW 90 rq"},
	{"XCHG", 2, {"r32","EAX"}, "r-", "o32 90 rd"},
	{"XCHG", 2, {"r64","RAX"}, "r-", "rxW 90 rq"},
	{"XCHG", 2, {"rm8","r8"}, "mr", "86 /r"},
	{"XCHG", 2, {"r8","rm8"}, "rm", "86 /r"},
	{"XCHG", 2, {"rm16","r16"}, "mr", "o16 87 /r"},
	{"XCHG", 2, {"r16","rm16"}, "rm", "o16 87 /r"},
	{"XCHG", 2, {"rm32","r32"}, "mr", "o32 87 /r"},
	{"XCHG", 2, {"rm64","r64"}, "mr", "rxW 87 /r"},
	{"XCHG", 2, {"r32","rm32"}, "rm", "o32 87 /r"},
	{"XCHG", 2, {"r64","rm64"}, "rm", "rxW 87 /r"},
	
	{"XGETBV", 0, {}, "", "0F 01 D0"},
	
	{"XLAT", 0, {}, "", "D7"},
	
	{"XOR", 2, {"AL","imm8"}, "-i", "34 ib"},
	{"XOR", 2, {"AX","imm16"}, "-i", "o16 35 iw"},
	{"XOR", 2, {"EAX","imm32"}, "-i", "o32 35 id"},
	{"XOR", 2, {"RAX","imm32"}, "-i", "rxW 35 id"},
	{"XOR", 2, {"rm8","imm8"}, "mi", "80 /6 ib"},
	{"XOR", 2, {"rm16","imm16"}, "mi", "o16 81 /6 iw"},
	{"XOR", 2, {"rm32","imm32"}, "mi", "o32 81 /6 id"},
	{"XOR", 2, {"rm64","imm32"}, "mi", "rxW 81 /6 id"},
	{"XOR", 2, {"rm16","imm8"}, "mi", "o16 83 /6 ib"},
	{"XOR", 2, {"rm32","imm8"}, "mi", "o32 83 /6 ib"},
	{"XOR", 2, {"rm64","imm8"}, "mi", "rxW 83 /6 ib"},
	{"XOR", 2, {"rm8","r8"}, "mr", "30 /r"},
	{"XOR", 2, {"rm16","r16"}, "mr", "o16 31 /r"},
	{"XOR", 2, {"rm32","r32"}, "mr", "o32 31 /r"},
	{"XOR", 2, {"rm64","r64"}, "mr", "rxW 31 /r"},
	{"XOR", 2, {"r8","rm8"}, "rm", "32 /r"},
	{"XOR", 2, {"r16","rm16"}, "rm", "o16 33 /r"},
	{"XOR", 2, {"r32","rm32"}, "rm", "o32 33 /r"},
	{"XOR", 2, {"r64","rm64"}, "rm", "rxW 33 /r"},
	
	--XORPD, XORPS
	
	{"XRSTOR", 1, {"m"}, "m", "0F AE /5"},
	{"XRSTOR64", 1, {"m"}, "m", "rxW 0F AE /5"},
	
	{"XSAVE", 1, {"m"}, "m", "0F AE /4"},
	{"XSAVE64", 1, {"m"}, "m", "rxW 0F AE /4"},
	
	{"XSAVEOPT", 1, {"m"}, "m", "0F AE /6"},
	{"XSAVEOPT64", 1, {"m"}, "m", "rxW 0F AE /6"},
	
	{"XSETBV", 0, {}, "", "0F 01 D1"},
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
