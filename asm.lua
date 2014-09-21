
ASM = {}

-- My own include function since lua doesnt have one
function include(fname)
	-- load the file into a function
	proc, err = loadfile("LuaASM/"..fname)
	if proc == nil then
		print(err)
		error()
	end
	-- run the function (i.e. same as doFile())
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

-- This creates a bunch of variables used later
function ASM:Init()
	ASM.FileList = {}
	ASM.BitSize = 16
	ASM.AddrSize = 16
	ASM.AddrType = "off"
	ASM.SourceFiles = {}
	ASM.Source = {}
	ASM.IncludeSearchPath = {}
	ASM.Tokens = {}
	ASM.WorkingDir = ".\\"
	ASM.Macros = {}
	ASM.CodeList = {}
	ASM.Labels = {}
	ASM.OutFmt = "bin"
	ASM.OutFname = "out.bin"
end

-- Parse the command line options
function ASM:ParseCmdLine(cmdarg)
	local state = ""
	-- Loop through all arguments
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
			elseif state == "f" then
				ASM.OutFmt = v
			elseif state == "o" then
				ASM.OutFname = v
			end
			state = ""
		else -- state ~= "" and v[0] == '-'
			if v == "-I" then
				state = "I"
			elseif v == "-f" then
				state = "f"
			elseif v == "-o" then
				state = "o"
			end
		end
	end
end

-- Actual compile function
function ASM:doCompile()
	print("Tokenizing...")
	self:tokenize() -- Tokenize source file
	print("Done. Result:")
	--printTable(self.Tokens)
	print("Expanding macros...")
	self:Expand() -- Expand macros
	print("Done. Result:")
	--printTable(self.Tokens)
	print("Parsing...")
	self:Parse() -- Parse code
	print("Done.")
	self:Encode() -- Encode
end

-- Main function
function ASM:Compile(cmdarg)
	print("Compile")
	self:Init() -- Set up vars
	self:ParseCmdLine(cmdarg) -- Parse our command line
	
	-- Bring in output format
	include("Output/" .. ASM.OutFmt .. ".lua")
	
	-- Compile each file
	for _,v in pairs(self.SourceFiles) do
		-- Open file
		local f = assert(io.open(v, "r"))
		-- Set up the file's structures
		self.Source[1] = {}
		self.Source[1].Src = f:read("*all")
		self.Source[1].Src = string.gsub(self.Source[1].Src, "\r\n","\n")
		self.Source[1].Line = 1
		self.Source[1].Col = 1
		self.Source[1].Fname = v
		f:close()
		
		-- Compile file
		self:doCompile()
	end
end

-- Debugging function
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

-- Debugging function
function printTable(Table, recur)
	local recur = recur or 0
	local tab = ""
	for i=0, recur do
		tab = tab .. "\t"
	end
	for i,j in pairs(Table) do
		local data = j
		if i ~= "Type" then
			strfmt = tab .. tostring(i) .. " : "
		else
			data = ASM.TOK_NAME[j]
		end
		if type(data) == "table" then
			strfmt = strfmt .. tostring(Table)
			print(strfmt)
			printTable(data, recur + 1)
		elseif type(data) == "number" then
			strfmt = strfmt .. string.format("0x%X",data)
			print(strfmt)
		else
			strfmt = strfmt .. tostring(data)
			print(strfmt)
		end
	end
end

-- Obsolete debugging function
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

-- Obsolete debugging function
function ASM:convToken()
	for i,j in pairs(self.Tokens) do
		j.Type = self.TOK_NAME[j.Type]
	end
end

-- Get our command line arguments
args = {...}

-- = binio.open("Test.bin", "wb")
--bugCheck(f)
--str = "Hello World!"
--f:writeByte(str:byte(1, -1))
--f:close()

-- Print them for debugging
for i,j in pairs(args) do
	print(j)
end

-- And now we compile
ASM:Compile(args)

--printTable(ASM.OPCODES)

return