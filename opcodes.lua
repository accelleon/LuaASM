
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
	
	{"MOVSB", 0, {}, "A4"},
	{"MOVSW", 0, {}, "A5", opflags.o16},
	{"MOVSD", 0, {}, "A5", opflags.o32},
	{"MOVSQ", 0, {}, "A5", opflags.o64},
}

ASM.OPCODES = {}

-- Initialize opcode table
for _, opcode in pairs(ASM.OPCODES_RAW) do
	name = opcode[1]
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