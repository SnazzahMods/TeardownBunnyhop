local mayConflictList = {
	"2433702881", -- Chaos Mod
}

local willConflictList = {
	"2415158477", -- Sprint and Walk
	"2417915839", -- Flymode
}

local compatTimer = 0
local willConflict = false
local conflicts = {}

function checkCompat()
	for i=1, #mayConflictList do
		local id = mayConflictList[i]
		local active = GetBool("mods.available.steam-"..id..".active")
		if active then
			willConflict = true
			table.insert(conflicts, '    ' .. GetString("mods.available.steam-"..id..".listname"))
		end
	end

	for i=1, #willConflictList do
		local id = willConflictList[i]
		local active = GetBool("mods.available.steam-"..id..".active")
		if active then
			willConflict = true
			table.insert(conflicts, '!!! ' .. GetString("mods.available.steam-"..id..".listname") .. ' !!!')
		end
	end
end

function compatDraw()
	if willConflict and compatTimer < 8 then
		compatTimer = compatTimer + GetTimeStep()

		local opacity = 1
		if compatTimer > 7 then
			opacity = 1 - (compatTimer - 7)
		end

		local header = "Bunnyhop Mod may conflict or cause problems with the following mods:"
		local text = ""
		for i=1, #conflicts do
			local name = conflicts[i]
			text = text .. "\n" .. name
		end

		UiPush()
			UiAlign("center bottom")
			UiTranslate(UiCenter(), UiHeight() - 70)
			UiFont("MOD/assets/ui/Roboto-Bold.ttf", 20)
			local hw, hh = UiGetTextSize(header)
			UiFont("MOD/assets/ui/Roboto-Regular.ttf", 20)
			local dw, dh = UiGetTextSize(text)
			UiColor(1, 1, 1, opacity)
			UiPush()
				UiTranslate(0, 5)
				UiColor(1, 0.25, 0.2, opacity)
				local mw = hw
				if dw > hw then mw = dw end
				UiRect(mw + 10, hh + dh + 10)
			UiPop()
			UiPush()
				UiTranslate(0, -dh)
				UiFont("MOD/assets/ui/Roboto-Bold.ttf", 20)
				UiText(header)
			UiPop()
			UiPush()
				UiFont("MOD/assets/ui/Roboto-Regular.ttf", 20)
				UiText(text)
			UiPop()
		UiPop()
	end
end