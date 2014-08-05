
ASM.TOK_PREPROC = {}

local function trimString(str)
  return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

-- Pushes a source file onto the stack
function ASM:PushFile(fname)
	f = io.open(fname)
	if f == nil then
		return false
	end
	local src = f:read("*a")
	f:close()
	table.insert(self.Source, 1,
		{ Src = src, Line = 1, Col = 1, Fname = fname })
end

-- Scans include paths and finds a given file
-- Returning full filename if found
function ASM:ResolveInclude(fname)
	for _,v in pairs(self.IncludeSearchPath) do
		f = io.open(v .. fname)
		if f ~= nil then
			f:close()
			return v .. fname
		end
	end
	return ""
end

-- Processes preprocessor line directives
function ASM:PreprocessLine(line, pos)
	local macroLine = string.sub(line,2)
	local tokens = self:tokenizeLine(macroLine)
	
	macroName = string.upper(tokens[1])
	macroParam = table.remove(tokens,1)
	
	if macroName == "PRAGMA" then
	elseif macroName == "DEFINE" then
		-- For now we store defined variables as tokens
		-- When expanded they simply replace the macro
		-- identifier with the tokens
		defName = macroParam[1].Data
		defVal = table.remove(macroParam,1)
		ASM.Defines[defName] = defVal
	elseif macroName == "INCLUDE" then
		local fname = ""
		if macroParam[1].Type == "STRING" then
			fname = macroParam[1].Data
			fname = ".\\" .. fname
		elseif macroParam[1].Type == "LSS" then
			if macroParam[3].Type ~= "GTR" then
				-- Error out improper preprocessor
				self:Error(3, self:GetFileLine())
			end
			fname = macroParam[2].Data
			fname = self:ResolveInclude(fname)
		end
		if fname == "" then
			-- Error out couldn't find file
			self:Error(4, self:GetFileLine())
		end
		if not self:PushFile(fname) then
			self:Error(5, self:GetFileLine(), fname)
		end
	else
		-- Error, not a preprocessor directive
		self:Error(6, self:GetFileLine())
	end
end

-- Performs expansion of macros
function ASM:Expand()
	for i,v in pairs(self.Tokens) do
		-- Macros are tokenized as identifiers
		-- Therefore we can ignore anything else
		if (v.Type == "IDENT") and (self.Defines[v.Data]) then
			-- Remove macro
			table.remove(self.Tokens, i)
			-- TODO: Cannot insert more than one value
			table.insert(self.Tokens, i, table.unpack(self.Defines[v.Data]))
		end
	end
end