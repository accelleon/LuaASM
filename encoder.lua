-- AccelASM encoder
-- The encoder works in 2 stages:
-- Stage 1 doesn't actually output any bytecode
--	instead it calculates offsets of labels
-- Stage 2 outputs the bytecode and parses
--	any non-constant expressions (i.e. expressions
--	that require labels

-- Table of ModR/M encodings
-- { Encoding:string, Mod:number, RM:number}
-- 16-bit addressing
ASM.ModRM16 = {
	["BX SI"] = {0,0},
	["BX DI"] = {0,1},
	["BP SI"] = {0,2},
	["BP DI"] = {0,3},
	["SI"] = {0,4},
	["DI"] = {0,5},
	["D16"] = {0,6},
	["BX"] = {0,7},
	
	["BX SI D8"] = {1,0},
	["BX DI D8"] = {1,1},
	["BP SI D8"] = {1,2},
	["BP DI D8"] = {1,3},
	["SI D8"] = {1,4},
	["DI D8"] = {1,5},
	["BP D8"] = {1,6},
	["BX D8"] = {1,7},
	
	["BX SI D16"] = {2,0},
	["BX DI D16"] = {2,1},
	["BP SI D16"] = {2,2},
	["BP DI D16"] = {2,3},
	["SI D16"] = {2,4},
	["DI D16"] = {2,5},
	["BP D16"] = {2,6},
	["BX D16"] = {2,7} }
	
-- 32/64-bit addressing
ASM.ModRM32 = {
	["AX"] = {0,0},
	["CX"] = {0,1},
	["DX"] = {0,2},
	["BX"] = {0,3},
	["SIB"] = {0,4},
	["EIP D32"] = {0,5},
	["RIP D32"] = {0,5},
	["SI"] = {0,6},
	["DI"] = {0,7},
	
	["AX D8"] = {1,0},
	["CX D8"] = {1,1},
	["DX D8"] = {1,2},
	["BX D8"] = {1,3},
	["SIB D8"] = {1,4},
	["BP D8"] = {1,5},
	["SI D8"] = {1,6},
	["DI D8"] = {1,7},
	
	["AX D32"] = {2,0},
	["CX D32"] = {2,1},
	["DX D32"] = {2,2},
	["BX D32"] = {2,3},
	["SIB D32"] = {2,4},
	["BP D32"] = {2,5},
	["SI D32"] = {2,6},
	["DI D32"] = {2,7} }
	
-- Since all registers can be represented above,
-- only 1 name has been used. This maps registers
-- with the same index to the 16-bit name
ASM.INDREG = {
	["EAX"] = "AX", ["EBX"] = "BX", ["ECX"] = "CX", ["EDX"] = "DX",
	["EBP"] = "BP", ["ESI"] = "SI", ["EDI"] = "DI", ["ESP"] = "SP",
	["AL"] = "AX", ["BL"] = "BX", ["CL"] = "CX", ["DL"] = "DX",
	["AH"] = "SP", ["BH"] = "DI", ["CH"] = "BP", ["DH"] = "SI" }
	
-- Returns mod and r/m for a certain encoding
function ASM:GetModRM(base,index,dispSz,addrSz)
	local str = ""
	
	if base ~= nil then
		str = str .. base:upper()
	end
	if index ~= nil then
		if base ~= nil then
			str = str .. " "
		end
		str = str .. index:upper()
	end
	if dispSz ~= nil and dispSz ~= 0 then
		if base ~= nil or index ~= nil then
			str = str .. " "
		end
		str = str .. "D" .. tostring(dispSz)
	end
	
	local modrm
	if addrSz == 16 then
		modrm = self.ModRM16[str]
	else
		modrm = self.ModRM32[str]
	end
	
	if not modrm then
		modrm = self:GetModRM(index,base,dispSz,addrSz)
	end
	
	if modrm ~= nil then
		return table.unpack(modrm)
	end
end

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
	print("Label " .. ident .. " equals: " .. val)
	self.Labels[ident] = val
end

function ASM:EncodeModRM(mod,reg,rm)
	mod = bit32.band(bit32.lshift(mod,6),0xC0)
	reg = bit32.band(bit32.lshift(reg,3),0x38)
	rm = bit32.band(rm,0x07)
	return bit32.band(bit32.bor(mod,reg,rm),0xFF)
end

function ASM:EncodeSIB(scale,index,base,mod)
	-- Adjust parameters to be correct
	local needDisp
	if not index then
		index = self.REG_LOOKUP["SP"]
	end
	if not base then
		if mod ~= 0 then
			-- Invalid EA
			error("I Quit!")
		end
		base = self.REG_LOOKUP["BP"]
		needDisp = true
	end
	-- We need to fix scale
	if scale == 1 then
		scale = 0
	elseif scale == 2 then
		scale = 1
	elseif scale == 4 then
		scale = 2
	elseif scale == 8 then
		scale = 3
	else
		error("Wrong scale")
	end

	scale = bit32.band(bit32.lshift(scale,6),0xC0)
	index = bit32.band(bit32.lshift(index,3),0x38)
	base = bit32.band(base,0x07)
	return bit32.band(bit32.bor(scale,index,base),0xFF), needDisp
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
	self.CurTok = 1
	
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
					ea.Ind = e.Data
					ea.Scale = e.Val
				end
				ea.Base = e.Data
			else
				-- Must be index
				if ea.Ind then
					self:Error(24, pos.File, pos.Line)
				end
				ea.Ind = e.Data
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

-- Returns nBytes, modrm, sib, dispSz, disp, addrSz
function ASM:ProcessEA(toks, rfield)
	-- First evaluate the effective address
	-- We do this here instead of the parser
	-- in case it has a label
	local pos, ea, reg
	if toks[1] ~= nil then
		-- It's a table, assume its an EA
		pos = toks[1].Pos
		ea = self:EvalEA(toks)
	elseif toks.Type ~= nil then
		-- It's a single token, assume 
		pos = toks.Pos
		reg = toks.Data
	else
		-- Hmm shouldn't be here
		error()
	end
	
	if not tonumber(rfield) then
		rfield = self.REG_LOOKUP[rfield]
		if not rfield then
			error("Wut")
		end
	end
	
	if ea.Scale == 0 then
		ea.Index = nil
	end
	
	if not ea.DispSz then
		ea.DispSz = 0
		ea.Disp = 0
	end

	if not ea.Base and not ea.Ind and not ea.Scale and not ea.Disp then
		error("Error parsing ea")
	end
	
	if reg ~= nil then
		-- Register
		local regType = self.REG_TYPE[reg]
		local addrSz
		if regType == "reg8" or regType == "reg16" then
			addrSz = 16
		elseif regType == "reg32" then
			addrSz = 32
		else
			addrSz = 64
		end
		
		return 1, self:EncodeModRM(3, rfield, self.REG_LOOKUP[reg]), nil, nil, nil, addrSz
	end
	
	if not ea.Base and not ea.Ind and not ea.Scale then
		-- Pure offset
		if self.BitSize == 64 then
			if ea.DispSz == 16 then
				-- We cannot address 16 bit displacements
				-- in 64-bit addressing
				self.Error(24, pos.File,pos.Line)
			end
		end
		
		if self.BitSize == 64 then
			-- 64-bit addressing
			if self.AddrType == "off" then
				-- Offset addressing, 32-bit displacement isn't available in
				-- modr/m alone in long mode, encode ModRM: SIB and SIB: disp32
				return 2, self:EncodeModRM(0, rfield, 4), self:EncodeModRM(0, 4, 5), 4, disp, 64
			else
				-- Relative addressing, encode EIP/RIP + disp
				return 1, self:EncodeModRM(0, rfield, 5), nil, 4, ea.Disp, 64
			end
		else
			-- 32/16 bit addressing
			if ea.DispSz == 32 then
				-- If more than 16-bits, encode disp32
				return 1, self:EncodeModRM(0, rfield, 5), nil, 4, ea.Disp, 32
			elseif ea.DispSz == 16 then
				-- Less than 16-bits, encode default address size
				if self.BitSize == 64 or self.BitSize == 32 then
					return 1, self:EncodeModRM(0, rfield, 6), nil, 4, ea.Disp, 32
				else
					return 1, self:EncodeModRM(0, rfield, 6), nil, 4, ea.Disp, 16
				end
			end
		end
	else
		local addrSz = 16
		if ea.DispSz == 32 or ea.Disp > 65535 then
			addrSz = 32
		end
		
		-- Size optimizations:
		-- [eax*2] and no disp -> eax*1 + eax
		if ea.Scale == 2 and not ea.Base and ea.DispSz == 0 then
			ea.Scale = 1
			ea.Base = ea.Ind
		end
		
		if not ea.Scale then
			-- We can assume we won't need an SIB byte in normal conditions
			local mod, rm = self:GetModRM(ea.Base, ea.Ind, ea.DispSz, addrSz)
			return 1, self:EncodeModRM(mod, rfield, rm), ea.DispSz, ea.Disp
		else			
			-- Encode the correct SIB modrm
			-- Special optimization for no base
			-- SIB with no base requires a 32-bit displacement
			local mod, rm
			if ea.Base then
				mod, rm = self:GetModRM("SIB", nil, ea.DispSz, 32)
			else
				mod, rm = self:GetModRM("SIB", nil, nil, 32)
			end
			local modrm = self:EncodeModRM(mod, rfield, rm)
		
			-- We absolutely need an SIB byte
			local index = self.REG_LOOKUP[ea.Ind]
			local base = self.REG_LOOKUP[ea.Base]
			local sib, needDisp = self:EncodeSIB(ea.Scale, index, base, mod)
			
			if needDisp then
				if not ea.Disp then
					ea.Disp = 0
				end
				ea.DispSz = 32
			end
			
			return 2, modrm, sib, ea.DispSz/8, ea.Disp
		end
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
			local size, modrm, sib, dSize, disp
			if OpEnc[curOp] == 'r' then
				local reg = getOp().Data
				size, modrm, sib, dSize, disp = self:ProcessEA(getOp().Data, reg)
			elseif OpEnc[curOp] == 'm' then
				size, modrm, sib, dSize, disp = self:ProcessEA(getOp().Data, getOp().Data())
			end
			if dSize then size = size + dSize end
			emitByte(size)
		elseif _rmtab[o] then
			-- Parse memory
			local rfield = string.sub(o,2,2)
			rfield = tonumber(rfield)
			local size, modrm, sib, dSize, disp = self:ProcessEA(getOp().Data, rfield)
			if dSize then size = size + dSize end
			emitByte(size)
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
	
	local emitWord
	local emitDword
	
	-- These functions assume little endian!
	local function emitByte(b, sz)
		if not b then return end
		if sz == 2 then
			emitWord(b)
			return
		elseif sz == 4 then
			emitDword(b)
			return
		end
		table.insert(Bytecode,bit32.band(b,0xFF))
	end
	
	emitWord = function(w)
		emitByte(bit32.band(w,0xFF))
		emitByte(bit32.band(bit32.rshift(w,8),0xFF))
	end
	
	emitDword = function(dw)
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
			local size, modrm, sib, dSize, disp
			if OpEnc[curOp] == 'r' then
				local reg = getOp().Data
				size, modrm, sib, dSize, disp = self:ProcessEA(getOp().Data, reg)
			elseif OpEnc[curOp] == 'm' then
				size, modrm, sib, dSize, disp = self:ProcessEA(getOp().Data, getOp().Data())
			end
			emitByte(modrm)
			if sib then emitByte(sib) end
			if dSize > 0 then emitByte(disp,dSize) end
		elseif _rmtab[o] then
			-- ModR/M byte in which only mod and r/m fields are used
			-- and the reg field indicates an extension to the opcode
			local rfield = string.sub(o,2,2)
			rfield = tonumber(rfield)
			local size, modrm, sib, dSize, disp = self:ProcessEA(getOp().Data, rfield)
			emitByte(modrm)
			if sib then emitByte(sib) end
			if disp then emitByte(disp,dSize) end
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
	return #Bytecode, Bytecode
end

function ASM:Encode()
	-- Phase 1 calculate offset and set labels
	local offset = 0
	for _,o in pairs(self.CodeList) do
		if o.Type == self.OPTYPE.INSTX then
			offset = offset + self:EncodeInstx(o)
			--offset = offset + self:SizeInstx(o)
		elseif o.Type == self.OPTYPE.DEFINE then
			-- db, dw, dd, dq
		elseif o.Type == self.OPTYPE.LABEL then
			-- Set label to offset
			self:SetLabel(o.Data,offset)
		end
	end
	
	-- Phase 2 actually encode
	local output = {}
	for _,o in pairs(self.CodeList) do
		if o.Type == self.OPTYPE.INSTX then
			local _, bytecode = self:EncodeInstx(o)
			for _,v in pairs(bytecode) do
				table.insert(output,v)
			end
		end
	end
	
	-- output bytecode
	print("Output:")
	printTable(output)
	
	local outfile = self.Output.Open(self.OutFname)
	self.Output.Write(outfile,output)
	self.Output.Close(outfile)
end