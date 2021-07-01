moddataPrefix = "savegame.mod."
currentDataVersion = 2

-- Save Utils
	function GetDataValue(path, stype)
		if stype == "string" then
			return GetString(moddataPrefix .. path)
		elseif stype == "bool" then
			return GetBool(moddataPrefix .. path)
		elseif stype == "int" then
			return GetInt(moddataPrefix .. path)
		elseif stype == "float" then
			return GetFloat(moddataPrefix .. path)
		end
	end

	function SetDataValue(path, value, useInt)
		local vtype = type(value)
		if vtype == "string" then
			return SetString(moddataPrefix .. path, value)
		elseif vtype == "boolean" then
			return SetBool(moddataPrefix .. path, value)
		elseif vtype == "number" then
			if useInt then
				return SetInt(moddataPrefix .. path, value)
			else
				return SetFloat(moddataPrefix .. path, value)
			end
		end
	end

	function SaveBool(path, value)
		SetBool(moddataPrefix .. path, value)
	end

	function SaveInt(path, value)
		SetInt(moddataPrefix .. path, value)
	end

	function SaveFloat(path, value)
		SetFloat(moddataPrefix .. path, value)
	end

	function SaveString(path, value)
		SetString(moddataPrefix .. path, value)
	end
-----

function migrateData()
	dataVersion = GetDataValue("version", "int")

	if dataVersion < 1 then
		SetDataValue("walkSpeed", 7)
		SetDataValue("debug", false)
		SetDataValue("autobhop", true)
		SetDataValue("showcompat", true)
		SetDataValue("fov", true)
		SetDataValue("clipAvoid.enable", true)
		SetDataValue("clipAvoid.mult", 1)
		SetDataValue("hoppo.enable", true)
		SetDataValue("hoppo.showDecimal", true)
		SetDataValue("hoppo.pos", 3, true)
		SetDataValue("hoppo.unit", 3, true)
		SetDataValue("sound.loopEnable", true)
		SetDataValue("sound.comboEnable", true)
		SetDataValue("strafe.mult", 1)
		SetDataValue("strafe.cap", 0.08)
	end

	if dataVersion < 2 then
		SetDataValue("movetype", 2)
	end

	SetDataValue("version", currentDataVersion, true)
	dataVersion = currentDataVersion
end

function revertToDefaultData()
	SetDataValue("walkSpeed", 7)
	SetDataValue("debug", false)
	SetDataValue("autobhop", true)
	SetDataValue("showcompat", true)
	SetDataValue("fov", true)
	SetDataValue("movetype", 2)
	SetDataValue("clipAvoid.enable", true)
	SetDataValue("clipAvoid.mult", 1)
	SetDataValue("hoppo.enable", true)
	SetDataValue("hoppo.showDecimal", true)
	SetDataValue("hoppo.pos", 3, true)
	SetDataValue("hoppo.unit", 3, true)
	SetDataValue("sound.loopEnable", true)
	SetDataValue("sound.comboEnable", true)
	SetDataValue("strafe.mult", 1)
	SetDataValue("strafe.cap", 0.08)
end

function applyData()
	walkSpeed = GetDataValue("walkSpeed", "float")
	enableDebug = GetDataValue("debug", "bool")
	autoBHop = GetDataValue("autobhop", "bool")
	showCompat = GetDataValue("showcompat", "bool")
	enableFov = GetDataValue("fov", "bool")
	moveType = GetDataValue("movetype", "int")
	clipAvoid = GetDataValue("clipAvoid.enable", "bool")
	clipAvoidMult = GetDataValue("clipAvoid.mult", "float")
	enableHoppometer = GetDataValue("hoppo.enable", "bool")
	hoppoShowDecimal = GetDataValue("hoppo.showDecimal", "bool")
	hoppoPos = GetDataValue("hoppo.pos", "int")
	hoppoUnit = GetDataValue("hoppo.unit", "int")
	enableSpeedLoop = GetDataValue("sound.loopEnable", "bool")
	enableComboSound = GetDataValue("sound.comboEnable", "bool")
	strafeMult = GetDataValue("strafe.mult", "float")
	strafeCap = GetDataValue("strafe.cap", "float")
end

function saveData()
	SetDataValue("walkSpeed", walkSpeed)
	SetDataValue("debug", enableDebug)
	SetDataValue("autobhop", autoBHop)
	SetDataValue("showcompat", showCompat)
	SetDataValue("fov", enableFov)
	SetDataValue("movetype", moveType)
	SetDataValue("clipAvoid.enable", clipAvoid)
	SetDataValue("clipAvoid.mult", clipAvoidMult)
	SetDataValue("hoppo.enable", enableHoppometer)
	SetDataValue("hoppo.showDecimal", hoppoShowDecimal)
	SetDataValue("hoppo.pos", hoppoPos, true)
	SetDataValue("hoppo.unit", hoppoUnit, true)
	SetDataValue("sound.loopEnable", enableSpeedLoop)
	SetDataValue("sound.comboEnable", enableComboSound)
	SetDataValue("strafe.mult", strafeMult)
	SetDataValue("strafe.cap", strafeCap)
end

function initData()
	migrateData()
	applyData()
end