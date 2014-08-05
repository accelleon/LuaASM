-- X86 Register reference
ASM.REGS = {}
ASM.REGS["REG8"] = 	{ "AL", "CL", "DL", "BL", "AH", "CH", "DH", "BH"}
ASM.REGS["REG16"] = { "AX", "CX", "DX", "BX", "SP", "BP", "SI", "DI"}
ASM.REGS["REG32"] = {"EAX","ECX","EDX","EBX","ESP","EBP","ESI","EDI"}
ASM.REGS["REG64"] = {"RAX","RCX","RDX","RBX","RSP","RBP","RSI","RDI"}
--ASM.REGS["SREG2"] =	{ "ES", "CS", "SS", "DS",   "",   "",   "",   ""}
ASM.REGS["SREG"] =  { "ES", "CS", "SS", "DS", "FS", "GS",   "",   ""}
ASM.REGS["CREG"] = 	{"CR0",   "","CR2","CR3","CR4",   "",   "",   ""}
ASM.REGS["DREG"] =	{"DR0","DR1","DR2","DR3",   "",   "","DR6","DR7"}

-- 64-bit mode offers 8 additional registers
-- using a different naming scheme
ASM.REGS64 = {}
ASM.REGS64["REG8"] = {"R0L","R1L","R2L","R3L","R4L","R5L","R6L","R7L",
					  "R8L","R9L","R10L","R11L","R12L","R13L","R14L","R15L"}

ASM.REG_TYPE = {}
for k,v in pairs(ASM.REGS) do
	for i,j in pairs(v) do
		ASM.REG_TYPE[j] = k
	end
end

ASM.REG_LOOKUP = {}
for k,v in pairs(ASM.REGS) do
	-- This loop is actually order sensitive
	-- The register's index MUST be correct
	for i=1, #v do
		-- Empty strings are reserved registers
		if v[i] ~= "" then
			ASM.REG_LOOKUP[v[i]] = i-1
		end
	end
end