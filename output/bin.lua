-- Binary output format

ASM.Output = {}

function ASM.Output.Open(fname)
	return io.open(fname,"wb")
end

function ASM.Output.Close(file)
	file:close()
end

function ASM.Output.Write(file,data)
	local str = string.char(table.unpack(data))
	file:write(str)
end