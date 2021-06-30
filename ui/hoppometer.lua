#include "../util/index.lua"

enableHoppometer = true

hoppoShowDecimal = true
hoppoAccent = {0.20392156862745098, 0.596078431372549, 0.8588235294117647}
hoppoPos = 3
-- 1 - top left
-- 2 - top right
-- 3 - bottom left
-- 3 - bottom right
hoppoUnit = 1
-- 1 - m/s
-- 2 - km/h
-- 3 - mph
enableComboSound = true

local wheelSize = 200
local visSpeed = 0
local visUnit = 'm/s'
local hoppoRot = 0
local topSpeed = 0
local topSpeedTime = 0
local topSpeedColor = {0.9450980392156862, 0.7686274509803922, 0.058823529411764705}
local duringJump = false
local jumps = 0
local jumpTimeout = 0
local jumpScale = 0
local hoppoLeft = true
local hoppoTop = true

function hoppometerTick()
	if jumpNextFrame and jumpTickDelay == 0 and GetPlayerVehicle() == 0 then
		jumps = jumps + 1
		jumpTimeout = 5
		jumpScale = 1
		duringJump = true
	else
		local timeoutScale = 1
		if moveSpeed < walkSpeed + 1 and isTouchingGround or GetPlayerVehicle() ~= 0 then
			timeoutScale = 5
		end
		jumpTimeout = jumpTimeout - GetTimeStep() * timeoutScale
	end

	if jumpTimeout <= 0 then
		jumpTimeout = 0
		jumps = 0
		if duringJump and enableComboSound then
			UiSound("MOD/assets/combo_cancel.ogg", 1, 1)
		end
		duringJump = false
	end
end

function hoppometerDraw()
	-- Variable calculating
		if hoppoPos ~= 1 and hoppoPos ~= 2 and hoppoPos ~= 3 and hoppoPos ~= 4 then
			hoppoPos = 1
		end

		hoppoLeft = hoppoPos == 1 or hoppoPos == 3
		hoppoTop = hoppoPos == 1 or hoppoPos == 2

		visSpeed = moveSpeed
		if hoppoUnit == 2 then
			visSpeed = moveSpeed * 3.6
			visUnit = 'km/h'
		elseif hoppoUnit == 3 then
			visSpeed = moveSpeed * 2.236936
			visUnit = 'mph'
		end

		if topSpeedTime <= 0 then
			topSpeedTime = 0
		else
			topSpeedTime = topSpeedTime - GetTimeStep()
		end

		if topSpeed < visSpeed then
			topSpeed = visSpeed
			topSpeedTime = 1
		end

		if jumpScale <= 0 then
			jumpScale = 0
		else
			if jumpScale == 1 and enableComboSound then
				UiSound("MOD/assets/combo.ogg", 1, 0.7 + (math.min(jumps, 10) - 1) / 10)
			end
			jumpScale = jumpScale - (GetTimeStep() * 3)
		end
	-----

	if disableMod then
		return
	end

	UiPush()
		if hoppoPos == 1 then
			UiAlign("top left")
			UiTranslate(20, 20)
			if string.find(GetString("game.levelid"), "hub") then
				UiTranslate(0, 30)
			end

			-- Info
			UiPush()
				UiTranslate(wheelSize/2, wheelSize/8)

				renderHoppoInfo()
			UiPop()

			-- Wheel
			UiPush()
				UiTranslate(wheelSize/2, wheelSize/2)

				renderHoppoWheel(wheelSize)
			UiPop()
		elseif hoppoPos == 2 then
			UiAlign("top right")
			UiTranslate(UiWidth() - 20, 20)
			if string.find(GetString("game.levelid"), "hub") then
				UiTranslate(0, 30)
			end

			-- Info
			UiPush()
				UiTranslate(-wheelSize/2, wheelSize/8)

				renderHoppoInfo()
			UiPop()

			-- Wheel
			UiPush()
				UiTranslate(-wheelSize/2, wheelSize/2)

				renderHoppoWheel(wheelSize)
			UiPop()
		elseif hoppoPos == 3 then
			UiAlign("bottom left")
			UiTranslate(20, UiHeight() - 20)

			-- Info
			UiPush()
				UiTranslate(wheelSize/2, -(wheelSize/8) * 5)

				renderHoppoInfo()
			UiPop()

			-- Wheel
			UiPush()
				UiTranslate(wheelSize/2, -wheelSize/2)

				renderHoppoWheel(wheelSize)
			UiPop()
		elseif hoppoPos == 4 then
			UiAlign("bottom right")
			UiTranslate(UiWidth() - 20,  UiHeight() - 20)

			-- Info
			UiPush()
				UiTranslate(-wheelSize/2, -(wheelSize/8) * 5)

				renderHoppoInfo()
			UiPop()

			-- Wheel
			UiPush()
				UiTranslate(-wheelSize/2, -wheelSize/2)

				renderHoppoWheel(wheelSize)
			UiPop()
		end
	UiPop()
end

function renderHoppoWheel(size)
	size = size or 50
	UiPush()
		UiAlign("center middle")
		UiColor(0.2, 0.2, 0.2)
		UiImageBox("MOD/assets/ui/circle.png", size, size, 0, 0)

		-- Wheel Anim
		UiPush()
			UiScale(0.9)
			UiRotate(hoppoRot)

			local speedAmount = 1
			if moveSpeed < 5 then
				speedAmount = 1 - ((5 - moveSpeed) / 5)
			end
			local opacityDist = 0.5 + (speedAmount * 0.5)

			UiColor(hoppoAccent[1], hoppoAccent[2], hoppoAccent[3], opacityDist)
			UiImageBox("MOD/assets/ui/wheel.png", size, size, 0, 0)

			if moveSpeed > 2 then
				hoppoRot = hoppoRot + math.pow(moveSpeed / 1, 1.2)
			end
			if hoppoRot > 360 then
				hoppoRot = hoppoRot - 360
			end
		UiPop()

		-- Number
		UiPush()
			UiTranslate(0, -size/20)
			UiColor(1, 1, 1)
			UiTextShadow(0, 0, 0, 0.5, 2.0)
			UiFont("MOD/assets/ui/Roboto-BoldItalic.ttf", 100)
			local decSplit = splitString(tostring(math.abs(visSpeed)), '.')
			decSplit[2] = decSplit[2] or '0'
			local w, h = UiGetTextSize(decSplit[1])
			UiText(decSplit[1])

			if hoppoShowDecimal then
				UiAlign("left top")
				UiTranslate(w/2, -h/2 + 5)
				UiFont("MOD/assets/ui/Roboto-LightItalic.ttf", 30)
				local decText = '.' .. string.sub(decSplit[2], 0, 1)
				w, h = UiGetTextSize(decText)
				UiColor(0.2, 0.2, 0.2, 0.5)
				UiRect(w, h)
				UiColor(1, 1, 1, 0.75)
				UiText(decText)
			end
		UiPop()

		-- Units
		UiPush()
			UiColor(1, 1, 1)
			UiTextShadow(0, 0, 0, 0.5, 2.0)
			UiTranslate(0, size/4)
			UiFont("MOD/assets/ui/Roboto-Regular.ttf", 30)
			UiText(visUnit)
		UiPop()
	UiPop()
end

function renderHoppoInfo()
	UiPush()
		local w = 300
		local h = 80
		if not hoppoLeft then
			UiTranslate(-w, 0)
		end
		UiAlign("top left")
		UiColor(0.15, 0.15, 0.15)
		UiImageBox("ui/common/box-solid-10.png", w, h, 10, 10)
		UiWindow(w, h, true)

		local barHeight = 30
		local barWidth = (jumpTimeout / 5) * (UiWidth() - ((wheelSize/2)))

		-- Jump Timeout
		if jumpTimeout > 0 then
			UiPush()
				if hoppoLeft then
					UiTranslate((wheelSize/2) - 20, UiHeight() - barHeight - 10)
				else
					UiTranslate(UiWidth() - (wheelSize/2) + 10, UiHeight() - barHeight - 10)
					UiAlign("top right")
				end
				UiColor(hoppoAccent[1], hoppoAccent[2], hoppoAccent[3])
				UiImageBox("ui/common/box-solid-6.png", barWidth, barHeight, 6, 6)
			UiPop()
		end

		-- Top Speed
		UiPush()
			if hoppoLeft then
				UiTranslate(UiWidth() - 10, 10)
				UiAlign("top right")
			else
				UiTranslate(10, 10)
				UiAlign("top left")
			end
			UiColor(
				topSpeedColor[1] + (1 - topSpeedTime) * (1 - topSpeedColor[1]),
				topSpeedColor[2] + (1 - topSpeedTime) * (1 - topSpeedColor[2]),
				topSpeedColor[3] + (1 - topSpeedTime) * (1 - topSpeedColor[3])
			)
			UiTextShadow(0, 0, 0, 0.5, 2.0)
			UiFont("MOD/assets/ui/Roboto-Bold.ttf", 20)
			local decSplit = splitString(tostring(math.abs(topSpeed)), '.')
			decSplit[2] = decSplit[2] or '0'
			UiText("Top Speed: " .. decSplit[1] .. '.' .. string.sub(decSplit[2], 0, 1) .. " " .. visUnit)
		UiPop()

		-- Jump Count
		UiPush()
			if jumps <= 0 then
				UiColor(0.5, 0.5, 0.5)
			else
				UiColor(1, 1, 1)
			end
			if hoppoLeft then
				UiTranslate((wheelSize/2) + 5, UiHeight() - barHeight/2 - 10)
				UiAlign("left middle")
			else
				UiTranslate(UiWidth() - ((wheelSize/2) + 5), UiHeight() - barHeight/2 - 10)
				UiAlign("right middle")
			end
			UiTextShadow(0, 0, 0, 0.5, 2.0)
			UiFont("MOD/assets/ui/Roboto-Black.ttf", 25)
			UiScale(1 + (jumpScale * 0.2))
			UiText(jumps .. 'x')
		UiPop()
	UiPop()
end