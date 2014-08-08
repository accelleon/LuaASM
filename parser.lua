-- Generates final listing before encoding
-- Takes tokens and puts them together into
-- a format that is easier to work with when encoding

-- Essentially tokens are put together into
-- instructions parameters, etc.

ASM.OPTYPE = {}
ASM.OPTYPE.INSTX = 1
ASM.OPTYPE.LABEL = 2
ASM.OPTYPE.DEFINE = 3 -- db, dw, dd, dq directives
ASM.OPTYPE.DIRECTIVE = 4 -- Assembler directives

function ASM:StringizeToken(tok)
	name = self.TOK_NAME[tok.Type]
	if name ~= nil then
		return self.TOK_NAME2[tok.Type][tok.Data]
	else
		return tok.Data
	end
end

function ASM:StringizeTokens(tokList)
	r = ""
	for i=1, #tokList do
		r = r .. self:StringizeToken(tokList[i])
	end
	return r
end

function ASM:GetToken(off)
	if not self.CurTok then
	end
	return self.Tokens[self.CurTok + (off or 0)]
end

function ASM:MatchToken(tok)
	if not self:GetToken() then
		return tok == self.TOKEN.EOF
	end
	
	if self:GetToken().Type == tok then
		self.TokenType = self.Tokens[self.CurTok].Type
		self.TokenData = self.Tokens[self.CurTok].Data
		self.TokenPos = self.Tokens[self.CurTok].Pos
		self.CurTok = self.CurTok + 1
		return true
	end
	return false
end

function ASM:NextTok()
	self.CurTok = self.CurTok + 1
end

function ASM:PeekToken(offset, extended)
	if self.Tokens[self.CurTok + (offset or 0)] then
		if extended then
			return self.Tokens[self.CurTok + (offset or 0)].Type,
				   self.Tokens[self.CurTok + (offset or 0)].Data
		else
			return self.Tokens[self.CurTok + (offset or 0)].Type
		end
	else
		return self.TOKEN.EOF
	end
end

function ASM:TokIter()
	local r = self:GetToken()
	self:NextTok()
	return r
end

function ASM:GetTokenPos(tok)
	if not tok then
		return self.TokenPos.File, self.TokenPos.Line
	else
		return tok.Pos.File, tok.Pos.Line
	end
end

-- This simply strips the square brackets
-- and puts the tokens into a table
-- to be evaluated later
function ASM:ParseMem(toks)
	local ret = {}
	local colon = false
	local inBracket = false
	local hasReg = false
	
	-- Save current state
	local _tok = self.Tokens
	local _cur = self.CurTok
	
	-- Use our tokens as the current state
	-- To make use of token functions
	self.Tokens = toks
	self.CurTok = 1
	
	if not self:MatchToken(self.TOKEN.LSQUARE) then
		-- Internal error we shouldn't be here
		-- if this isn't an effective address
		self:Error(7, nil, nil, 1)
	end
	
	while not self:MatchToken(self.TOKEN.RSQUARE) do
		if self:PeekToken() == self.TOKEN.EOF then
			self:Error(20, self:GetTokenPos(self:GetToken(-1)))
		end
		if self:PeekToken() == self.TOKEN.REG then
			hasReg = true
		end
		table.insert(ret, self:TokIter())
	end
	
	-- Restore token state
	self.Tokens = _tok
	self.CurTok = _cur
	
	if ret == {} then
		self:Error(19, self:GetTokenPos())
	end
	return hasReg,ret
end

-- Splits operands separated by commas
function ASM:SplitOperands()
	local ops = {}
	local tmpOp = {}
	local nOps = 0
	while true do
		if (self:GetToken().Type == self.TOKEN.COMMA) or
		   (self:GetToken().Type == self.TOKEN.NL) or
		   (self:GetToken().Type == self.TOKEN.EOF) then
			nOps = nOps + 1
			table.insert(ops, tmpOp)
			tmpOp = {}
			
			if self:GetToken().Type ~= self.TOKEN.COMMA then
				break
			else
				self:TokIter()
			end
		else
			table.insert(tmpOp, self:TokIter())
		end
	end
	return nOps, ops
end

function ASM:ParseDef()
	local def = {}
	def.Type = self.OPTYPE.DEFINE
	def.SubType = self.TokenData
	def.List = {}
	
	local nOps, ops = self:SplitOperands()
	
	-- For define types only constants and strings are allowed
	for i,o in pairs(ops) do
		local tmpOp = {}
		
		if o[1].Type == self.TOKEN.STRING then
			if #o ~= 1 then
				-- Error nothing may follow a string literal
				-- There should be a comma
				self:Error(8, self:GetTokenPos(o[1]))
			end
			tmpOp.Type = "string"
			tmpOp.Data = o[1].Data
		else
			-- Constant expression
			-- We'll just point the data to the list of tokens
			-- This is done in case it contains a label
			-- which cannot be evaluated until stage 2 of encoding
			tmpOp.Type = "const"
			tmpOp.SubType = "exp"
			tmpOp.Data = o
		end
		if tmpOp ~= {} then
			table.insert(def.List, tmpOp)
		end
	end
	return def
end

-- Parses an instruction
-- This is quite difficult as
-- the interpretation of the operands changes
-- based on other operands and some opcodes work for set
-- registers and are faster than their counterparts.
--( i.e. mov al ... has its own opcode, etc)
-- Due to this, mapping instructions
-- is most likely the slowest part of assembly. It
-- continuously has to reference the OPCODES table

function ASM:ParseInstx(prefix)
	--print("Instruction!")
	local Name = self.TokenData
	local instx = {}
	local file, line = self:GetTokenPos()
	instx.Type = self.OPTYPE.INSTX
	instx.Pos = self.TokenPos
	
	local nOps, ops = self:SplitOperands()
	
	if not self.OPCODES[Name][nOps] then
		-- Incorrect number of operands
		self:Error(10, file, line)
	end
	
	-- now we actually interpret the operands
	-- remember that its a table of tables of tokens
	-- I really hope this is parsed in order
	local sizeType
	local opType = {}
	for i,o in pairs(ops) do
		local tmpOp = {}
		local sizeType
		
		if o[1].Type == self.TOKEN.SIZE then
			sizeType = o[1].Data
			table.remove(o,1)
		end
		
		if o[1].Type == self.TOKEN.REG then
			if #o > 1 then
				-- Error out, this isn't memory
				-- so we can't have more than 1 token with a register
				self:Error(11, file, line)
			end
			if sizeType ~= nil then
				-- Error out, size specifier cannot act on register
				self:Error(12, file, line)
			end
			tmpOp.Type = "reg"
			tmpOp.SubType = self.REG_TYPE[o[1].Data]
			tmpOp.Data = o[1].Data
		elseif o[1].Type == self.TOKEN.LSQUARE then
			-- Effective address
			tmpOp.Type = "m"
			tmpOp.Reg,tmpOp.Data = self:ParseMem(o)
			tmpOp.Size = sizeType
		else
			-- Immediate expression
			tmpOp.Type = "imm"
			tmpOp.Data = o
			tmpOp.Size = sizeType
		end
		if tmpOp ~= {} then
			table.insert(opType, tmpOp)
		end
	end
	
	-- Determine the types of the operands
	-- This is a very complex operation
	-- as encoding varies greatly
	-- notably in differences between moffsX
	-- and mX types, some instructions
	-- have a special encoding for specific
	-- registers which is generally faster
	-- than encoding it normally
	
	-- first test for size prefixes
	-- prefix verification isn't done till later
	-- after we determine the flags of the instruction
	-- but we need the size to determine operand types
	-- and to verify operands
	local size
	if prefix ~= nil then
		for _,p in pairs(prefix) do
			if tonumber(p) then
				size = tonumber(p)
			end
		end
	end
	-- No size prefix, grab whatever
	-- size we're currently using
	-- Changed via the [BITS X] directive
	if not size then
		size = self.BitSize
	end
	
	-- Lookup table for register types
	local _types = {}
	_types["REG8"] = "r8"
	_types["REG16"] = "r16"
	_types["REG32"] = "r32"
	_types["REG64"] = "r64"
	_types["SREG"] = "Sreg"
	_types["CREG"] = "Creg"
	_types["DREG"] = "Dreg"
	
	-- first operand type pass
	-- recognizes explicit size
	for i,o in pairs(opType) do
		if o.Type == "reg" then
			o.Type = _types[o.SubType]
			o.SubType = nil
		elseif o.Type == "m" then
			if o.Size ~= nil then
				o.Type = o.Type .. tostring(o.Size)
			end
		elseif o.Type == "imm" then
			if o.Size ~= nil then
				o.Type = o.Type .. tostring(o.Size)
			end
		end
	end
	
	-- Table of best guesses of operand size
	-- based on size of another
	-- We can ignore control and debug registers
	-- because they can only be accessed via registers
	-- which will always have a size specifier
	local _guess = {}
	_guess["r8"] = 8
	_guess["r16"] = 16
	_guess["r32"] = 32
	_guess["r64"] = 64
	_guess["m8"] = 8
	_guess["m16"] = 16
	_guess["m32"] = 32
	_guess["m64"] = 64
	_guess["imm8"] = 8
	_guess["imm16"] = 16
	_guess["imm32"] = 32
	_guess["imm64"] = 64
	
	-- Segment registers are a special case
	-- They can be accessed with 64 or 16 bit memory
	if size == 64 then
		_guess["Sreg"] = 64
	else
		_guess["Sreg"] = 16
	end
	
	-- second pass
	-- guess sizes for operand sizes that aren't
	-- explicitly expressed
	local sizeGuess
	for i,o in pairs(opType) do
		if (_guess[o.Type]) and (not sizeGuess) then
			sizeGuess = _guess[o.Type]
		end
	end
	
	-- Size isn't specified
	-- Default to current bit size
	if not sizeGuess then
		sizeGuess = size
	end
	
	-- Add size to types that
	-- don't have one yet
	for i,o in pairs(opType) do
		if (o.Type == "imm") or (o.Type == "m") then
			o.Type = o.Type .. tostring(sizeGuess)
		end
	end
	
	-- Table to convert mX to moffsX
	local _moff = {}
	_moff["m8"] = "moffs8"
	_moff["m16"] = "moffs16"
	_moff["m32"] = "moffs32"
	_moff["m64"] = "moffs64"
	
	-- Every operand should now represent the correct
	-- type be it implicit or explicit
	-- So now lets bruteforce the correct operand types
	-- using our guess as a basis
	
	-- first build a table of possible operands
	local possOps = {}
	for i,o in pairs(opType) do
		local possOp = {}
		-- We'll try register names and moffsX first
		local ch = string.sub(o.Type,1,1)
		if ch == 'm' then
			-- Memory type
			-- If memory doesn't include a register
			-- then try moffsX as a type
			if (not o.Reg) then
				-- Put together type information first
				local tMoff = {}
				local tSize = o.Data.Size or sizeGuess
				tMoff.Type = "moffs" .. tostring(tSize)
				tMoff.Data = o.Data
				
				-- Add it as a possible operand
				table.insert(possOp, tMoff)
			end
			-- Add mX as a possible operand
			table.insert(possOp, o)
		elseif ch == 'r' then
			-- Register type
			-- Try the register's name
			-- Put together type information
			local tReg = {}
			tReg.Type = o.Data
			--tReg.Data = self.REG_LOOKUP[o.Data]
			tReg.Data = o.Data
			-- We want to keep register names for encoding
			
			-- Change regX's data to contain index
			--o.Data = tReg.Data
			-- Nevermind don't do that we need the name
			-- for the expression evaluator
			
			-- Add both as a possible operand
			table.insert(possOp, tReg)
			table.insert(possOp, o)
		else
			-- Immediate type
			-- Just add it to possible operands
			table.insert(possOp, o)
		end
		table.insert(possOps, possOp)
	end
	
	-- Local recursive function that
	-- builds a unique path from given
	-- operands each time its called
	
	-- i is the operand index
	-- t is a table that the path is built in
	-- and p is the table of tried pathways
	
	-- will return false once pathways
	-- branching from operand are exhausted
	local function _test(i, t, p)
		-- Don't go beyond the number of operands
		if i > nOps then
			return false
		end
	
		-- loop through the possible operand
		-- types for i
		for _,v in pairs(possOps[i]) do
			-- Grab or create our pathway
			p[v] = p[v] or {}
			-- Have we run out of possibilities
			-- that branch from this operand?
			if not p[v].Done then
				-- Not yet, add this operand to the path
				table.insert(t,v)
				-- next recursive call
				local tst = _test(i+1,t,p[v])
				if not tst then
					-- We've run out of operands
					-- that branch from this one
					-- Finish off this branch
					p[v].Done = true
				end
				return true
			end
		end
		-- We've exhausted our current branch
		return false
	end
	
	
	-- Now we try every possible pathway
	local tried = {}
	local res
	-- Loop until instx.Operands has a value
	while not instx.Operands do
		local path = {}
		-- Build a path
		if not _test(1,path,tried) then
			-- We've run out of paths
			-- Instruction doesn't have given types
			self:Error(13, file, line)
		else
			local tmp = self.OPCODES[Name][nOps]
			local correct = true
			-- Try each operand
			for _,o in pairs(path) do
				-- Does it have an entry for this type?
				if tmp[o.Type] then
					-- Yes move down the chain
					tmp = tmp[o.Type]
					--print(o.Type .. " Correct")
				else
					-- No, wrong pathway
					correct = false
					--print(o.Type .. " Wrong")
					break
				end
			end
			-- Did we finish our pathway?
			-- tmp[1] test is required because
			-- it seems my recursive function
			-- can spit out nil values
			if correct and tmp[1] then
				-- Yes we did, we're done with our
				-- loop
				instx.Operands = path
				res = tmp
				break
			end
		end
	end
	
	-- Get the encoding and flags
	instx.OpEncode = res[1]
	instx.Bytecode = res[2]
	instx.Flags = res[3]
	instx.nOperands = nOps
	
	-- Now we verify our prefixes
	
	--printTable(instx)
	
	return instx
end

-- Parses token output
function ASM:Parse()
	self.CurTok = 1
	local TOKEN = self.TOKEN
	
	while self:PeekToken() ~= TOKEN.EOF do
		local code
		if self:MatchToken(TOKEN.PREFIX) then
			--print(self.TokenData)
			local prefix = {self.TokenData}
			while self:MatchToken(TOKEN.PREFIX) do
				table.insert(prefix, self.TokenData)
			end
			if not self:MatchToken(TOKEN.OPCODE) then
				-- Error opcode or another prefix must follow
				-- a prefix
				self:Error(14, self:GetTokenPos())
			end
			code = self:ParseInstx(prefix)
		elseif self:MatchToken(TOKEN.OPCODE) then
			code = self:ParseInstx()
		elseif self:MatchToken(TOKEN.DEF) then
			code = self:ParseDef()
		elseif self:PeekToken() == TOKEN.IDENT then
			if self:PeekToken(1) == TOKEN.COLON then
				code = {}
				code.Type = self.OPTYPE.LABEL
				self:MatchToken(TOKEN.IDENT)
				code.Data = self.TokenData
				self:MatchToken(TOKEN.COLON)
			else
				-- Why is this here?
				self:Error(15, self:GetTokenPos())
			end
		elseif self:MatchToken(TOKEN.NL) then
		else
			-- Unknown token
			self:Error(16, self:GetTokenPos())
		end
		if code ~= nil then
			table.insert(self.CodeList,code)
		end
	end
end