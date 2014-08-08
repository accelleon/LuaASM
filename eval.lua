ASM.EXPR = {}
ASM.TOREG = {}

local ind = 1
local fsreg = false
for _,r in pairs(ASM.REGS) do
	for _,reg in pairs(r) do
		if r == "SREG" then
			if not fsreg then
				fsreg = true
				ASM.EXPR.SREG_START = ind
			end
			ASM.EXPR.SREG_END = ind
		end
		ASM.EXPR[reg] = ind
		ASM.TOREG[ind] = reg
		ind = ind + 1
	end
end

ASM.EXPR.REGEND = ind
ASM.EXPR.SIMPLE = ind + 1
ASM.EXPR.SEGBASE = ind + 2

SEG_ABS = 0x400000000

function is_sreg(t)
	return (t >= ASM.EXPR.SREG_START) and (t <= ASM.EXPR.SREG_END)
end

local tmpexpr = {}
function addtotemp(Type, Val, Data)
	local e = {}
	e.Type = Type
	e.Val = Val
	e.Data = Data
	table.insert(tmpexpr,e)
end

function finishtemp()
	addtotemp(0,0)
	r = tmpexpr
	tmpexpr = {}
	return r
end

local hint = {}

function is_simple(vec)
	local nScalar = false
	local seg = false
	
	for _,e in pairs(vec) do
		if e.Type == ASM.EXPR.SIMPLE then
			if nScalar then
				return false
			end
			nScalar = true
		elseif e.Type == ASM.EXPR.SEGBASE then
			if not nScalar then
				return false
			end
		end
	end
	return true
end

function is_really_simple(vec)
	local nScalar = false
	
	for _,e in pairs(vec) do
		if e.Type == ASM.EXPR.SIMPLE then
			if nScalar then
				-- 2 scalar values, not simple
				return false
			end
			-- We found a scalar value
			nScalar = true
		else
			return false
		end
	end
	
	return true
end

function reloc_value(vec)
	for _,e in pairs(vec) do
		if e.Type == ASM.EXPR.SIMPLE then
			
			return e.Val
		end
	end
	return 0
end

function scalarmult(vec, scalar, hints)
	local last
	
	for _,e in pairs(vec) do
		e.Val = scalar * e.Val
		if hints and hint.Type == "MAKE" then
			if hint.Base == e.Type then
				hint.Type = "NOTBASE"
			end
		end
		
		if e.Type >= ASM.EXPR.SEGBASE + SEG_ABS then
			table.remove(vec, _)
			break
		end
	end
	
	return vec
end

function addvectors(p,q)
	local preserve = is_really_simple(p) or is_really_simple(q)
	local n = math.max(#p, #q)
	local ip, iq = 1, 1
	local tmp = false
	
	for i=1, n do
		if p[ip].Type >= ASM.EXPR.SEGBASE + SEG_ABS or
		   q[iq].Type >= ASM.EXPR.SEGBASE + SEG_ABS then
		   break
		end
		
		if p[ip].Type > q[iq].Type then
			addtotemp(q[iq].Type, q[iq].Val, q[iq].Data)
			iq = iq + 1
		elseif p[ip].Type < q[iq].Type then
			addtotemp(p[ip].Type, p[ip].Val, p[ip].Data)
			ip = ip + 1
		else
			addtotemp(p[ip].Type, p[ip].Val + q[iq].Val, p[ip].Data)
			ip = ip + 1
			iq = iq + 1
		end
	end
	
	for ip=ip, #p do
		if p[ip].Type >= ASM.EXPR.SEGBASE + SEG_ABS then
			if preserve then
				addtotemp(p[ip].Type, p[ip].Val, p[ip].Data)
			end
		else
			addtotemp(p[ip].Type, p[ip].Val, p[ip].Data)
		end
		--ip = ip + ip
	end
	
	for iq=iq, #q do
		if q[iq].Type >= ASM.EXPR.SEGBASE + SEG_ABS then
			if preserve then
				addtotemp(q[iq].Type, q[iq].Val, q[iq].Data)
			end
		else
			addtotemp(q[iq].Type, q[iq].Val, q[iq].Data)
		end
		--iq = iq + iq
	end
	
	local r = finishtemp()
	return r
end

function scalar(val)
	addtotemp(ASM.EXPR.SIMPLE,val)
	return finishtemp()
end

function ASM:Eval_Level4()

	--[[if self:MatchToken(self.TOKEN.PLUS) then
		print("fk")
		return self:Eval_Level4()]]
		
	if self:MatchToken(self.TOKEN.MINUS) then
		local e = self:Eval_Level3()
		if not e then return nil end
		return scalarmult(e, -1, false)
		
	elseif self:MatchToken(self.TOKEN.BITNOT) then
		local e = self:Eval_Level4()
		if not e then return nil end
		return scalar(bit32.bnot(reloc_value(e)))
		
	elseif self:MatchToken(self.TOKEN.LPAREN) then
		local e = self:Eval_Level0()
		if not e then return nil end
		if not self:MatchToken(self.TOKEN.RPAREN) then
			-- Error unclosed parenthesis
			self:Error(17, self:GetTokenPos())
		end
		return e
		
	elseif self:MatchToken(self.TOKEN.NUMBER) or
		   self:MatchToken(self.TOKEN.CHAR) or
		   self:MatchToken(self.TOKEN.IDENT) or
		   self:MatchToken(self.TOKEN.REG) then
		
		if (self.TokenType == self.TOKEN.NUMBER) or
		   (self.TokenType == self.TOKEN.CHAR) then
			addtotemp(self.EXPR.SIMPLE, self.TokenData)
		
		elseif self.TokenType == self.TOKEN.IDENT then
			if not self:GetLabel(self.TokenData) then
				-- Undefined label
				self:Error(23,self:GetTokenPos())
			end
			addtotemp(self.EXPR.SIMPLE, self:GetLabel(self.TokenData))
			
		elseif self.TokenType == self.TOKEN.REG then
			addtotemp(self.EXPR[self.TokenData], 1, self.TokenData)
			if not hint.Type then
				hint.Type = "MAKE"
				hint.Base = self.EXPR[self.TokenData]
			end
		end
		return finishtemp()
	else
		local file, line = self:GetTokenPos()
		self:Error(18, file, line, self.TOK_NAME[self:GetToken().Type])
	end
end

function ASM:Eval_Level3()
	local e = self:Eval_Level4()
	if not e then return nil end
	
	while self:MatchToken(self.TOKEN.MULTIPLY) or
		  self:MatchToken(self.TOKEN.DIVIDE) or
		  self:MatchToken(self.TOKEN.MODULUS) do
		  
		local tokType = self.TokenType
		local f = self:Eval_Level4()
		if not f then return nil end
		
		if tokType == self.TOKEN.MULTIPLY then
			if is_simple(e) then
				e = scalarmult(f, reloc_value(e), true)
			elseif is_simple(f) then
				e = scalarmult(e, reloc_value(f), true)
			else
				error("Error Me")
			end
		elseif tokType == self.TOKEN.DIVIDE then
			e = scalar(reloc_value(e) / reloc_value(f))
		elseif tokType == self.TOKEN.MODULUS then
			e = scalar(reloc_value(e) % reloc_value(f))
		end
	end
	return e
end

function ASM:Eval_Level2()
	local e = self:Eval_Level3()
	if not e then return nil end

	while self:MatchToken(self.TOKEN.PLUS) or
	      self:MatchToken(self.TOKEN.MINUS) do
		  
		local tokType = self.TokenType
		  
		local f = self:Eval_Level3()
		if not f then return nil end
		  
		if tokType == self.TOKEN.PLUS then
			e = addvectors(e, f)
		elseif tokType == self.TOKEN.MINUS then
			e = addvectors(e, scalarmult(f, -1, false))
		end
	end
	return e
end

function ASM:Eval_Level1()
	local e = self:Eval_Level2()
	if not e then return nil end
	
	while self:MatchToken(self.TOKEN.SHR) or
		  self:MatchToken(self.TOKEN.SHL) do
		  
		local tokType = self.TokenType
		local f = self:Eval_Level2()
		if not f then return nil end
		
		if tokType == self.TOKEN.SHR then
			e = scalar(bit32.rshift(reloc_value(e), reloc_value(f)))
		elseif tokType == self.TOKEN.SHL then
			e = scalar(bit32.lshift(reloc_value(e), reloc_value(f)))
		end
	end
	return e
end

function ASM:Eval_Level0()
	local e = self:Eval_Level1()
	if not e then return nil end
	
	while self:MatchToken(self.TOKEN.BITAND) or
		  self:MatchToken(self.TOKEN.BITOR) or
		  self:MatchToken(self.TOKEN.BITXOR) do
		  
		local tokType = self.TokenType
		local f = self:Eval_Level1()
		if not f then return nil end
		
		if tokType == self.TOKEN.BITAND then
			e = scalar(bit32.band(reloc_value(e), reloc_value(f)))
		elseif tokType == self.TOKEN.BITXOR then
			e = scalar(bit32.band(reloc_value(e), reloc_value(f)))
		elseif tokType == self.TOKEN.BITOR then
			e = scalar(bit32.bor(reloc_value(e), reloc_value(f)))
		end
	end
	return e
end

function ASM:Eval(toks,restore)
	if toks then
		local _tok = self.Tokens
		local _cur = self.CurTok
		
		self.Tokens = toks
		self.CurTok = 1
	end
	
	hint = {}
	
	local e = self:Eval_Level0()
	if not e then return nil end
	
	e = scalarmult(e, 1, false)
	
	if toks and restore then
		self.Tokens = _tok
		self.CurTok = _cur
	end
	
	return e, hint
end