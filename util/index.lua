function splitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function stringLeftPad(str, len, char)
	if char == nil then char = ' ' end
	return str .. string.rep(char, len - #str)
end

function fixMoveSpeed()
	if moveSpeed < 0 then
		moveSpeed = 0
	end
end

function NumLerp(a, b, t)
	return (a * (1 - t)) + (b * t)
end

function VecDir(a, b)
	return VecNormalize(VecSub(b, a))
end