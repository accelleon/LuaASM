--[[ tokens listing ]]--
ASM.TOKEN_TEXT = {}
ASM.TOKEN_TEXT["IDENT"] = 		{}
ASM.TOKEN_TEXT["NUMBER"] = 		{}
ASM.TOKEN_TEXT["LPAREN"] = 		{"("}
ASM.TOKEN_TEXT["RPAREN"] = 		{")"}
ASM.TOKEN_TEXT["LBRACKET"] = 	{"{"}
ASM.TOKEN_TEXT["RBRACKET"] =	{"}"}
ASM.TOKEN_TEXT["LSQUARE"] =		{"["}
ASM.TOKEN_TEXT["RSQUARE"] =		{"]"}
ASM.TOKEN_TEXT["SEMICOLON"] =	{";"}
ASM.TOKEN_TEXT["COLON"] =		{":"}
ASM.TOKEN_TEXT["HASH"] =		{"#"}
ASM.TOKEN_TEXT["COMMA"] =		{","}
ASM.TOKEN_TEXT["DOT"] =			{"."}

-- Unary operations
ASM.TOKEN_TEXT["INC"] =			{"++"}
ASM.TOKEN_TEXT["DEC"] =			{"--"}
-- Binary operations
ASM.TOKEN_TEXT["MULTIPLY"] =	{"*"}
ASM.TOKEN_TEXT["DIVIDE"] =		{"/"}
ASM.TOKEN_TEXT["MODULUS"] =		{"%"}
ASM.TOKEN_TEXT["PLUS"] =		{"+"}
ASM.TOKEN_TEXT["MINUS"] = 		{"-"}
ASM.TOKEN_TEXT["POWER"] =		{"^^"}
-- Assignment operators
ASM.TOKEN_TEXT["EQUAL"] =		{"="}
ASM.TOKEN_TEXT["ADDEQL"] =		{"+="}
ASM.TOKEN_TEXT["SUBEQL"] =		{"-="}
ASM.TOKEN_TEXT["MULEQL"] =		{"*="}
ASM.TOKEN_TEXT["DIVEQL"] =		{"/="}
-- Bitwise functions
ASM.TOKEN_TEXT["BITNOT"] =		{"~"}
ASM.TOKEN_TEXT["BITAND"] =		{"&"}
ASM.TOKEN_TEXT["BITOR"] =		{"|"}
ASM.TOKEN_TEXT["BITXOR"] =		{"^"}
ASM.TOKEN_TEXT["SHL"] =			{"<<"}
ASM.TOKEN_TEXT["SHR"] =			{">>"}
-- Test operators
ASM.TOKEN_TEXT["EQL"] =			{"=="}
ASM.TOKEN_TEXT["NEQL"] =		{"!="}
ASM.TOKEN_TEXT["LEQ"] =			{"<="}
ASM.TOKEN_TEXT["LSS"] =			{"<"}
ASM.TOKEN_TEXT["GEQ"] =			{">="}
ASM.TOKEN_TEXT["GTR"] =			{">"}
-- Boolean operators
ASM.TOKEN_TEXT["NOT"] =			{"!"}
ASM.TOKEN_TEXT["AND"] =			{"&&"}
ASM.TOKEN_TEXT["OR"] =			{"||"}

-- Keywords
ASM.TOKEN_TEXT["GOTO"] =		{"GOTO"}
ASM.TOKEN_TEXT["FOR"] =			{"FOR"}
ASM.TOKEN_TEXT["IF"] =			{"IF"}
ASM.TOKEN_TEXT["ELSE"] =		{"ELSE"}
ASM.TOKEN_TEXT["WHILE"] =		{"WHILE"}
ASM.TOKEN_TEXT["DO"] =			{"DO"}
ASM.TOKEN_TEXT["SWITCH"] =		{"SWITCH"}
ASM.TOKEN_TEXT["CASE"] =		{"CASE"}
ASM.TOKEN_TEXT["CONST"] =		{"CONST"}
ASM.TOKEN_TEXT["RETURN"] =		{"RETURN"}
ASM.TOKEN_TEXT["BREAK"] =		{"BREAK"}
ASM.TOKEN_TEXT["CONTINUE"] =	{"CONTINUE"}
ASM.TOKEN_TEXT["PRESERVE"] =	{"PRESERVE"}

ASM.TOKEN_TEXT["ENUM"] =		{"ENUM"}
ASM.TOKEN_TEXT["STRUCT"] =		{"STRUCT"}
ASM.TOKEN_TEXT["TYPEDEF"] =		{"TYPEDEF"}

-- Specific keywords
ASM.TOKEN_TEXT["EXPORT"] =		{"__EXPORT"}
ASM.TOKEN_TEXT["INLINE"] =		{"__INLINE"}
ASM.TOKEN_TEXT["REGISTER"] =	{"__REGISTER"}

ASM.TOKEN_TEXT["ORG"] =			{"ORG"}

ASM.TOKEN_TEXT["SZPREFIX"] =	{"a16","a32","a64"}
ASM.TOKEN_TEXT["PREFIX"] =		{"LOCK","REPNE","REPNZ","REP","REPE","REPZ"}
ASM.TOKEN_TEXT["SIZE"] =		{[8]="BYTE", [16]="WORD", [32]="DWORD", [64]="QWORD"}
ASM.TOKEN_TEXT["DEF"] =			{"DB","DW","DD","DQ"}

ASM.TOKEN_TEXT["REG"] =			{}
ASM.TOKEN_TEXT["OPCODE"] =		{}

ASM.TOKEN_TEXT["COMMENT1"] =	{"//"}
ASM.TOKEN_TEXT["COMMENT2"] =	{"/*"}
ASM.TOKEN_TEXT["COMMENT3"] =	{"*/"}

-- Assembly retains newline characters
-- Where-as C can do without them
-- Since this is the assembler we
-- Tokenize them, however multiple newlines
-- are compacted into one
ASM.TOKEN_TEXT["NL"] =			{"\n"}
ASM.TOKEN_TEXT["STRING"] =		{}
ASM.TOKEN_TEXT["CHAR"] =		{}
ASM.TOKEN_TEXT["EOF"] =			{}

ASM.TOKEN = {}
ASM.TOK_NAME = {}
ASM.TOK_NAME2 = {}
local idx = 1
for tokenName, tokenData in pairs(ASM.TOKEN_TEXT) do
	ASM.TOKEN[tokenName] = idx
	ASM.TOK_NAME[idx] = tokenName
	ASM.TOK_NAME2[idx] = {}
	
	for k,v in pairs(tokenData) do
		ASM.TOK_NAME2[idx][k] = v
	end
	idx = idx + 1
end

ASM.TOK_LOOKUP = {}
for symID, symList in pairs(ASM.TOKEN_TEXT) do
	for symSubId, symText in pairs(symList) do
		if symID == "SZPREFIX" then
			-- Special case for size prefixes
			local n = tonumber(string.sub(symText,2))
			if n ~= nil then
				ASM.TOK_LOOKUP[symText] = {n, ASM.TOKEN["PREFIX"] }
			else
				-- Internal error generating lookup table
				error()
			end
		elseif symID == "PREFIX" or symID == "DEF" then
			ASM.TOK_LOOKUP[symText] = {symText, ASM.TOKEN[symID] }
		else
			ASM.TOK_LOOKUP[symText] = { symSubID, ASM.TOKEN[symID] }
		end
	end
end

for k,v in pairs(ASM.OPCODES) do
	ASM.TOK_LOOKUP[k] = {k, ASM.TOKEN.OPCODE}
end

for k,v in pairs(ASM.REG_LOOKUP) do
	ASM.TOK_LOOKUP[k] = {k, ASM.TOKEN.REG}
end

ASM.TOK_DBCHAR = {}
for symID, symList in pairs(ASM.TOKEN_TEXT) do
	local symText = symList or ""
	if #symText == 2 then
		local char1 = string.sub(symText,1,1)
		local char2 = string.sub(symText,2,2)
		ASM.TOK_DBCHAR[char1] = ASM.TOK_DBCHAR[char1] or {}
		ASM.TOK_DBCHAR[char1][char2] = true
	end
end