-- AccelASM encoder
-- The encoder works in 2 stages:
-- Stage 1 doesn't actually output any bytecode
--	instead it calculates offsets of labels
-- Stage 2 outputs the bytecode and parses
--	any non-constant expressions (i.e. expressions
--	that require labels

-- Table of ModR/M encodings
-- REG1, REG2, DISPSZ

function SplitString(str,delim)
	local ret = {}
	local delim = delim or " "
	local tmp = ""
	for i=1, #str do
		local ch = string.sub(str,i,i)
		if not string.find(delim,ch) then
			tmp = tmp .. ch
		else
			table.insert(ret,tmp)
			tmp = ""
		end
	end
	
	if tmp ~= "" then
		table.insert(ret,tmp)
	end
	
	if #ret < 1 then
		return nil
	else
		return ret
	end
end

function ASM:GetLabel(ident)
	return self.Labels[ident]
end

function ASM:SetLabel(ident, val)
	self.Labels[ident] = val
end

function ASM:EncodeModRM(mod,reg,rm)
	mod = bit32.band(bit32.lshift(mod,6),0xC0)
	reg = bit32.band(bit32.lshift(reg,3),0x38)
	rm = bit32.band(rm,0x07)
end

-- Possible returns:
-- .Scale = scale of index register
-- .Base = base register
-- .Disp = displacement
-- .DispSz = displacement size
-- .Index = index register
-- .Segment = segment override

-- Format:
-- [segment : index*scale + base + disp]
function ASM:EvalEA(toks)
	local pos = toks[1].Pos
	
	local ea = {}
	
	self.Tokens = toks
	self.CurToken = 1
	
	if self:MatchToken(self.TOKEN.SIZE) then
		ea.DispSz = self.TokenData
	end

	local ev, hint = self:Eval()
	if self:MatchToken(self.TOKEN.COLON) then
		if not is_sreg(ev[1].Type) or #ev > 1 then
			self:Error(25,pos.File,pos.Line)
		end
		if self:MatchToken(self.TOKEN.SIZE) then
			ea.DispSz = self.TokenData
		end
		ev, hint = self:Eval()
	end
	
	for _,e in pairs(ev) do
		-- Is it a register?
		if e.Type == 0 then
			break
		end
		if e.Type < ASM.EXPR.REGEND	then
			if e.Val == 1 then
				-- It could be a base register
				if ea.Base then
					-- Seems we already have a base
					-- Throw this to index
					if ea.Ind then
						self:Error(24, pos.File, pos.Line)
					end
					ea.Ind = e.Type
					ea.Scale = e.Val
				end
				ea.Base = e.Type
			else
				-- Must be index
				if ea.Ind then
					self:Error(24, pos.File, pos.Line)
				end
				ea.Ind = e.Type
				ea.Scale = e.Val
			end
		else
			if e.Type == self.EXPR.SIMPLE then
				if ea.Disp then
					self:Error(24, pos.File, pos.Line)
				end
				ea.Disp = e.Val
			end
		end
	end
	
	return ea
end

-- Returns nBytes, modrm, sib
function ASM:ProcessEA(toks, rfield)
	-- First evaluate the effective address
	-- We do this here instead of the parser
	-- in case it has a label
	local ea = self:EvalEA(toks)
	printTable(ea)
	
	if ea.Scale == 0 then
		ea.Ind = nil
	end
	
	if not ea.Base and not ea.Ind and not ea.Scale and not ea.Disp then
		error("Error parsing ea")
	end
	
	if not ea.Base and not ea.Ind and not ea.Scale then
		-- Pure offset
		
	end
	
	return 0
end

local _rmtab = {}
for i=0,7 do
	_rmtab["/" .. tostring(i)] = i
end

function ASM:SizeInstx(code)
	local Size = 0
	local Encoding = SplitString(code.Bytecode)
	
	local function emitByte(n)
		if not n then
			Size = Size + 1
		else
			Size = Size + n
		end
	end
	
	for _,o in pairs(Encoding) do
		if o == "o16" then
			if self.BitSize ~= 16 then
				emitByte()
			end
		elseif o == "o32" then
			if self.BitSize == 16 then
				emitByte()
			end
		elseif o == "o64" then
			emitByte()
		elseif o == "/r" then
			-- Parse memory
			-- For now assume 1 byte
			emitByte()
		elseif _rmtab[o] then
			-- Parse memory
			-- For now assume 1 byte
			emitByte()
		elseif (o == "ib") or (o == "iw") or (o == "id") then
			if o == "ib" then
				emitByte()
			elseif o == "iw" then
				emitByte(2)
			elseif o == "id" then
				emitByte(4)
			end
		elseif (o == "db") or (o == "dw") or (o == "dd") then
			if o == "db" then
				emitByte()
			elseif o == "dw" then
				emitByte(2)
			elseif o == "dd" then
				emitByte(4)
			end
		elseif (o == "rb") or (o == "rw") or (o == "rd") then
		elseif tonumber(o) then
			emitByte()
		end
	end
	
	return Size
end

-- Returns byte table
function ASM:EncodeInstx(code)
	local OpEnc = {}
	local Encoding
	
	-- Split the string into characters
	local opEncode = code.OpEncode
	for i=1, code.nOperands do
		table.insert(OpEnc,string.sub(opEncode,i,i))
		opEncode = string.sub(opEncode,i)
	end
	
	if #OpEnc ~= code.nOperands then
		-- Opcode table most likely corrupt
		-- or incorrect
		self:Error(7,nil,nil,2)
	end
	
	Encoding = SplitString(code.Bytecode)
	
	local Bytecode = {}
	local curOp = 1
	local Ops = code.Operands
	
	-- Here we remove Operands that map with '-' i.e.
	-- operands that aren't encoded
	for i,o in pairs(OpEnc) do
		if o == '-' then
			table.remove(Ops,i)
			table.remove(OpEnc,i)
		end
	end
	
	-- These functions assume little endian!
	local function emitByte(b)
		table.insert(Bytecode,bit32.band(b,0xFF))
	end
	
	local function emitWord(w)
		emitByte(bit32.band(w,0xFF))
		emitByte(bit32.band(bit32.rshift(w,8),0xFF))
	end
	
	local function emitDword(dw)
		emitWord(bit32.band(dw,0xFFFF))
		emitWord(bit32.band(bit32.rshift(dw,16),0xFFFF))
	end
	
	local function getOp()
		r = Ops[curOp]
		curOp = curOp + 1
		return r
	end
	
	local function expectOpType(t)
		if Ops[curOp].Type ~= t then
			-- Incorrect operand type
			-- We should never end up here since operand type handling
			-- is done during parsing
			self:Error(7, code.Pos.File, code.Pos.Line, 3)
		end
	end
	
	for _,o in pairs(Encoding) do
		print(o)
		if o == "o16" then
			if self.BitSize ~= 16 then
				-- Emit operand size prefix
				-- when BITS is not 16
				emitByte(0x66)
			end
		elseif o == "o32" then
			if self.BitSize == 16 then
				-- Emit operand size prefix
				-- only when BITS is 16
				emitByte(0x66)
			end
		elseif o == "/r" then
			-- ModR/M byte in which both r/m and reg fields are used
			local modrm, sib
			if OpEnc[curOp] == 'r' then
				local reg = getOp().Data
				modrm, sib = self:ProcessEA(getOp().Data, reg)
			elseif OpEnc[curOp] == 'm' then
				modrm, sib = self:ProcessEA(getOp().Data, getOp().Data())
			end
			emitByte(modrm)
			if sib then emitByte(sib) end
		elseif _rmtab[o] then
			-- ModR/M byte in which only mod and r/m fields are used
			-- and the reg field indicates an extension to the opcode
			local rfield = string.sub(o,2,2)
			rfield = tonumber(rfield)
			local modrm, sib = self:ProcessEA(getOp().Data, rfield)
			emitByte(modrm)
			if sib then emitByte(sib) end
		elseif (o == "ib") or (o == "iw") or (o == "id") then
			-- Immediate operand
			local val = self:Eval(getOp().Data)
			val = reloc_value(val)
			if o == "ib" then
				emitByte(val)
			elseif o == "iw" then
				emitWord(val)
			elseif o == "id" then
				emitDword(val)
			end
		elseif (o == "db") or (o == "dw") or (o == "dd") then
			-- Displacement value
			local val = self:Eval(getOp().Data)
			val = reloc_value(val)
			if o == "db" then
				emitByte(val)
			elseif o == "dw" then
				emitWord(val)
			elseif o == "dd" then
				emitDword(val)
			end
		elseif (o == "rb") or (o == "rw") or (o == "rd") then
			-- Register value added to previous byte
			local regInd = self.REG_LOOKUP[getOp().Data]
			Bytecode[#Bytecode] = Bytecode[#Bytecode] + regInd
		elseif tonumber(o,16) then
			emitByte(tonumber(o,16))
		else
			self:Error(7,nil,nil,4)
		end
	end
	
	printTable(Bytecode)
end

function ASM:Encode()
	-- Phase 1
	for _,o in pairs(self.CodeList) do
		if o.Type == self.OPTYPE.INSTX then
			self:EncodeInstx(o)
		end
	end
end