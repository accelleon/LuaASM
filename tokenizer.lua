

function ASM:nextFile()
	-- Save fname and line in case of EOF
	local tmp = self.Source[1]
	table.remove(self.Source, 1)
	if not self.Source[1] then
		self.Source[1] = tmp
	end
end

function ASM:getChar()
	local char = string.sub(self.Source[1].Src,1,1)
	if char == "" then
		self:nextFile()
		char = string.sub(self.Source[1].Src,1,1)
	end
	return char
end

function ASM:nextChar()
	local source = self.Source[1]
	if source.Src == "" then
		self:nextFile()
	else
		local ch = string.sub(source.Src,1,1)
		if ch == "\n" then
			source.Line = source.Line + 1
			source.Col = 1
		else
			source.Col = source.Col + 1
		end
		source.Src = string.sub(source.Src,2)
		return true
	end
end

function ASM:skipSpace()
	local nl = false
	local ch = self:getChar()
	local tokPos = { Line = self.Source[1].Line,
					 Col = self.Source[1].Col,
					 File = self.Source[1].Fname }
	while (ch == " ") or
		  (ch == "\t") or
		  (ch == "\n") do
		  -- If we encounter a nl write the first one
		  -- and ignore others
		if (not nl) and (ch == "\n") then
			table.insert(self.Tokens, {
			Type = self.TOKEN.NL,
			Data = nil,
			Pos = tokPos })
			nl = true
		end
		self:nextChar()
		ch = self:getChar()
	end
end

function ASM:GetFileLine()
	return self.Source[1].Fname, self.Source[1].Line
end

function ASM:doToken()
	local TOKEN = self.TOKEN
	self:skipSpace()
	
	local tokPos = { Line = self.Source[1].Line,
					 Col = self.Source[1].Col,
					 File = self.Source[1].Fname }
	
	if self:getChar() == "" then
		table.insert(self.Tokens, {
			Type = TOKEN.EOF,
			Data = nil,
			Pos = tokPos })
		return false
	end
	
	if (tokPos.Col == 1) and (self:getChar() == "%") then
		local macroLine = ""
		while (self:getChar() ~= "") and (self:getChar() ~= "\n") do
			macroLine = macroLine .. self:getChar()
			self:nextChar()
		end
		
		self:PreprocessLine(macroLine, tokPos)
		return true
	end
	
	if (self:getChar() == "'") or (self:getChar() == "\"") then
		local stringType = self:getChar()
		self:nextChar()
		
		local str = ""
		while (self.Source.Src ~= "") and (self:getChar() ~= "'")
			and (self:getChar() ~= "\"") do
			
			if self:getChar() == "\\" then
				self:nextChar()
				local ch = self:getChar()
					if ch == "'" 	then str = str .. "'"
				elseif ch == "\"" 	then str = str .. "\""
				elseif ch == "a" 	then str = str .. "\a"
				elseif ch == "b"	then str = str .. "\b"
				elseif ch == "f"	then str = str .. "\f"
				elseif ch == "r"	then str = str .. "\r"
				elseif ch == "n"	then str = str .. "\n"
				elseif ch == "t"	then str = str .. "\t"
				elseif ch == "v"	then str = str .. "\v"
				elseif ch == "0"	then str = str .. "\0"
				end
				self:nextChar()
			elseif self:getChar() == "\n" then
				-- Error out unfinished string
				self:Error(2, self:GetFileLine())
			else
				str = str .. self:getChar()
				self:nextChar()
			end
		end
		self:nextChar()
		
		if (stringType == "'") and (#str == 1) then
			table.insert(self.Tokens, {
				Type = TOKEN.CHAR,
				Data = string.byte(str),
				Pos = tokPos })
		else
			table.insert(self.Tokens, {
				Type = TOKEN.STRING,
				Data = str,
				Pos = tokPos })
		end
		return true
	end
	
	-- Fetch token
	local token = ""
	while string.find(self:getChar(), "[%w_.@]") do
		token = token .. self:getChar()
		self:nextChar()
	end
	
	if token == "" then
		token = self:getChar()
		self:nextChar()
		
		if ASM.TOK_DBCHAR[token] then
			if ASM.TOK_DBCHAR[token][self:getChar()] then
				token = token .. curChar
				self:nextChar()
				if token == "//" then
					while (self:getChar() ~= "") and (self:getChar() ~= "\n") do self:nextChar() end
					return true
				elseif token == "/*" then
					while self:getChar() ~= "" do
						local ch = self:getChar()
						self:nextChar()
						if(ch == "*") and (self:getChar() == "/") then
							self:nextChar()
							return true
						end
					end
					self:Error(1, self:GetFileLine())
					return true
				elseif token == "*/" then
					self:Error(9, self:GetFileLine())
					return true
				end
			end
		end
	end
	
	-- determine token
	local tokenLookup = self.TOK_LOOKUP[string.upper(token)]
	if tokenLookup then
		table.insert(self.Tokens, {
			Type = tokenLookup[2],
			Data = tokenLookup[1],
			Pos = tokPos })
		return true
	end
	
	-- number?
	if tonumber(token) then
		table.insert(self.Tokens, {
			Type = TOKEN.NUMBER,
			Data = tonumber(token),
			Pos = tokPos })
		return true
	end
	
	-- identifier
	table.insert(self.Tokens, {
		Type = TOKEN.IDENT,
		Data = token,
		Pos = tokPos })
	return true
end

function ASM:tokenize()
	while self:doToken() do
	end
end

function ASM:tokenizeLine(line)
	local prevToken = self.Tokens
	local prevSource = self.Source
	self.Tokens = {}
	self.Source = {}
	print(self.Tokens)
	print(prevToken)
	self.Source[1] = {Src = line, Line = 1, Col = 1, Fname = "none"}
	while self:doToken() do end
	local ret = self.Tokens
	self.Tokens = prevToken
	self.Source = prevSource
	return ret
end