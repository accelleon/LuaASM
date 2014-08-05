
ASM.ERROR_STR = {
	[1] = "Unexpected EOF",
	[2] = "Unclosed string",
	[3] = "Incorrect %include directive",
	[4] = "Failed to locate include file (%s)",
	[5] = "Failed to open include file (%s)",
	[6] = "Incorrect preprocessing directive",
	[7] = "Internal error %i",
	[8] = "Expected comma after string literal",
	[9] = "Unexpected comment end",
	[10] = "Incorrect number of operands",
	[11] = "Expected comma after register",
	[12] = "Size keyword cannot act on register",
	[13] = "No instruction with given operands",
	[14] = "An instruction or another prefix must follow a prefix",
	[15] = "Unexpected character",
	[16] = "Unknown token",
	[17] = "Unclosed parenthesis",
	[18] = "Unexpected token in expression",
	[19] = "Empty effective address",
	[20] = "Expected ']'",
	[21] = "Operand mismatch, expected %s got %s",
	[22] = "Multiple segment overrides",
	[23] = "Undefined identifier",
	[24] = "Invalid effective address",
	[25] = "Invalid segment override",
}

ASM.WARNING_STR = {
}

ASM.ERROR = {}

local idx = 1
for _,v in pairs(ASM.ERROR_STR) do
	ASM.ERROR[idx] = v
	idx = idx + 1
end

function ASM:Format(file, line)
	local fmt = ""
	if file ~= nil then
		fmt = fmt .. file
	end
	if line ~= nil then
		fmt = fmt .. "(" .. line .. ")"
	end
	if fmt ~= nil then
		fmt = fmt .. " "
	end
	return fmt
end

function ASM:Error(err, file, line, ...)
	local fmt = string.format("%sError %i: %s",
		self:Format(file, line), err, self.ERROR_STR[err])
	print(string.format(fmt), ...)
	error()
end

function ASM:Warning(warn, file, line, ...)
	local fmt = string.format("%s Warning: %s",
		self:Format(file, line), err)
	print(string.format(fmt, ...))
end