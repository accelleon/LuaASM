
ASM = {}

function include(fname)
	proc, err = loadfile(fname)
	if proc == nil then
		print(err)
		error()
	end
	proc()
end

include("opcodes.lua")
include("regs.lua")
include("tokens.lua")
include("preprocess.lua")
include("tokenizer.lua")
--include("expression.lua")
include("eval.lua")
include("parser.lua")
include("encoder.lua")
include("error.lua")


function ASM:Init()
	ASM.FileList = {}
	ASM.BitSize = 16
	ASM.AddrSize = 16
	ASM.SourceFiles = {}
	ASM.Source = {}
	ASM.IncludeSearchPath = {}
	ASM.Tokens = {}
	ASM.WorkingDir = ".\\"
	ASM.Macros = {}
	ASM.CodeList = {}
	ASM.Labels = {}
end

function ASM:ParseCmdLine(cmdarg)
	local state = ""
	for _,v in pairs(cmdarg) do
		if (state ~= "") and (v[0] == '-') then
			-- A state is set but we encountered a switch
			return 1
		elseif (state == "") and (v[0] ~= '-') then
			-- A state is not set and it isn't a switch
			-- Must be a source file
			table.insert(self.SourceFiles, v)
		elseif (state ~= "") and (v[0] ~= '-') then
			-- A state is set and it isn't a switch
			-- Probably second half of a switch
			if state == "I" then
				table.insert(self.IncludeSearchPath, v)
				local str = string.format("Added \"%s\" as include path", v)
				print(str)
			end
			state = ""
		else -- state ~= "" and v[0] == '-'
			if v == "-I" then
				state = "I"
			end
		end
	end
end

function ASM:doCompile()
	print("Tokenizing...")
	self:tokenize() -- Tokenize source file
	print("Done. Result:")
	printTable(self.Tokens)
	print("Expanding macros...")
	self:Expand() -- Expand macros
	print("Done. Result:")
	printTable(self.Tokens)
	print("Parsing...")
	self:Parse() -- Parse code
	print("Done.")
	self:Encode()
end

function ASM:Compile(cmdarg)
	print("Compile")
	self:Init()
	self:ParseCmdLine(cmdarg)
	
	for _,v in pairs(self.SourceFiles) do
		local f = assert(io.open(v, "r"))
		self.Source[1] = {}
		self.Source[1].Src = f:read("*all")
		self.Source[1].Src = string.gsub(self.Source[1].Src, "\r\n","\n")
		self.Source[1].Line = 1
		self.Source[1].Col = 1
		self.Source[1].Fname = v
		f:close()
		
		self:doCompile()
	end
end

function bugCheck(obj)
	local tbl = getmetatable(obj)
	if tbl == nil then
		return
	end

	print("Type: " .. type(obj))
	print(tbl)

	for i,j in pairs(tbl) do
		str = string.format("Key: %s Value: %s", i, j)
		print(str)
	end
end

function printTable(Table, recur)
	local recur = recur or 0
	local tab = ""
	for i=0, recur do
		tab = tab .. "\t"
	end
	for i,j in pairs(Table) do
		strfmt = tab .. tostring(i) .. " : "
		if type(j) == "table" then
			strfmt = strfmt .. tostring(Table)
			print(strfmt)
			printTable(j, recur + 1)
		else
			strfmt = strfmt .. tostring(j)
			print(strfmt)
		end
	end
end

function writeTable(file, Table, recur)
	local recur = recur or 0
	local tab = ""
	for i=0, recur do
		tab = tab .. "\t"
	end
	for i,j in pairs(Table) do
		strfmt = tab .. tostring(i) .. " : "
		if type(j) == "table" then
			strfmt = strfmt .. tostring(Table)
			file:write(strfmt .. "\n")
			writeTable(file, j, recur + 1)
		else
			strfmt = strfmt .. tostring(j)
			file:write(strfmt .. "\n")
		end
	end
end

function ASM:convToken()
	for i,j in pairs(self.Tokens) do
		j.Type = self.TOK_NAME[j.Type]
	end
end

args = {...}

-- = binio.open("Test.bin", "wb")
--bugCheck(f)
--str = "Hello World!"
--f:writeByte(str:byte(1, -1))
--f:close()

for i,j in pairs(args) do
	print(j)
end

f = io.open("token.lst", "w")
writeTable(f, ASM.OPCODES)
f:close()

ASM:Compile(args)

--printTable(ASM.OPCODES)

return