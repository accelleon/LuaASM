-- AccelASM expression evaluator

function ASM:Eval_Level3()
	local sign = 1
	if self:MatchToken(self.TOKEN.MINUS) then sign = -1 end
	if self:MatchToken(self.TOKEN.PLUS) then sign = 1 end
	
	if self:MatchToken(self.TOKEN.NUMBER) or
	   self:MatchToken(self.TOKEN.CHAR) then
		return true, self.TokenData * sign
	elseif self:MatchToken(self.TOKEN.LPAREN) then
		local isConst, Val = self:Eval_Level0()
		if not isConst then return false end
		if not self:MatchToken(self.TOKEN.RPAREN) then
			-- Error unclosed parenthesis
			self:Error(17, self:GetTokenPos())
		end
		return true, Val * sign
	elseif self:MatchToken(self.TOKEN.IDENT) then
		if not self:GetLabel(self.TokenData) then
			return false
		end
	else
		self:Error(18, self:GetTokenPos())
	end
	-- Wasn't a constant
	return false
end

function ASM:Eval_Level2()
	local lConst, lVal = self:Eval_Level3()
	if not lConst then return false end
	
	local token = self:PeekToken()
	if (token == self.TOKEN.MULTIPLY) or
	   (token == self.TOKEN.DIVIDE) or
	   (token == self.TOKEN.POWER) or
	   (token == self.TOKEN.MODULUS) then
		self:NextToken()
		local rConst, rVal = self:Eval_Level2()
		if not rConst then return false end
		
		if token == self.TOKEN.MULTIPLY then return true, lVal * rVal end
		if token == self.TOKEN.DIVIDE then return true, lVal / rVal end
		if token == self.TOKEN.POWER then return true, lVal ^ rVal end
		if token == self.TOKEN.MODULUS then return true, lVal % rVal end
	else
		return true, lVal
	end
end

function ASM:Eval_Level1()
	local lConst, lVal = self:Eval_Level2()
	if not lConst then return false end
	
	local token = self:PeekToken()
	if (token == self.TOKEN.PLUS) or
	   (token == self.TOKEN.MINUS) then
		if token == self.TOKEN.PLUS then self:NextToken() end
		local rConst, rVal = self:Eval_Level1()
		if not rConst then return false end
		
		return true, lVal + rVal
	elseif (token == self.TOKEN.AND) or
		   (token == self.TOKEN.OR) or
		   (token == self.TOKEN.XOR) then
		self:nextToken()
		local rConst, rVal = self:Eval_Level0()
		if not rConst then return false end
		
		if token == self.TOKEN.BITAND then return true, bit32.band(lVal, rVal) end
		if token == self.TOKEN.BITOR then return true, bit32.bor(lVal, rVal) end
		if token == self.TOKEN.BITXOR then return true, bit32.bxor(lVal, rVal) end
	else
		return true, lVal
	end
end

function ASM:Eval_Level0()
	local lConst, lVal = self:Eval_Level1()
	if not lConst then return false end
	
	if self:MatchToken(self.TOKEN.SHR) then
		local rConst, rVal = self:Eval_Level0()
		if not rConst then return false end
		return true, bit32.rshift(lVal, rVal)
	elseif self:MatchToken(self.TOKEN.SHL) then
		local rConst, rVal = self:Eval_Level0()
		if not rConst then return false end
		return true, bit32.lshift(lVal, rVal)
	end
	return true, lVal
end

function ASM:Eval(toks)
	local _tok = self.Tokens
	local _cur = self.CurTok
	
	self.Tokens = toks
	self.CurTok = 1
	
	local isConst, val = self:Eval_Level0()
	
	self.Tokens = _tok
	self.CurTok = _cur
	
	if not isConst then
		return nil
	else
		return val
	end
end