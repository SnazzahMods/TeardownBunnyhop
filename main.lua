#include "ui/hoppometer.lua"
#include "ui/compat.lua"
#include "util/data.lua"

-- Options
strafeMult = 1
strafeCap = 0.08
autoBHop = true
walkSpeed = 7
clipAvoid = true
clipAvoidMult = 1
enableDebug = false
enableFov = true
enableSpeedLoop = true
enableComboSound = true
showCompat = true

-- Variables
speedUpSpeed = 45
slowDownSpeed = 30
disableMod = false
moveSpeed = 0
jumpNextFrame = false
lastForwardMovement = 0
lastRightMovement = 0
rayDist = 0.5

moving = false
isTouchingGround = false
groundBelow = false
jumpTickDelay = 0

speedLoop = 0

function init()
	initData()
	checkCompat()

	speedLoop = LoadLoop("MOD/assets/speed.ogg")

	-- Disable Mod in certain levels
	local id = GetString("game.levelid")
	if id == "about" then
		disableMod = true
		return
	end
end

function tick(dt)
	if disableMod or GetBool('level.disableBHop') then
		return
	end

	if enableHoppometer then
		hoppometerTick()
	end

	moveSpeed = math.abs(moveSpeed)
	local toWalkSpeed = walkSpeed

	local playerVel = VecCopy(GetPlayerVelocity())
	playerVel[1] = 0
	playerVel[3] = 0

	-- Crouching
		if InputDown("crouch") then
			toWalkSpeed = walkSpeed / 2
		end
	----

	-- Get awareness variables
		local cameraTransform = GetCameraTransform()
		rayDist = 0.5 + (math.max(20, moveSpeed) - 20) / 3

		local frontDirection = TransformToParentVec(cameraTransform, {0, 0, -1})
		local somethingInFront = QueryRaycast(cameraTransform.pos, frontDirection, rayDist)

		local backDirection = TransformToParentVec(cameraTransform, {0, 0, 1})
		local somethingBehind = QueryRaycast(cameraTransform.pos, backDirection, rayDist)

		local leftDirection = TransformToParentVec(cameraTransform, {-1, 0, 0})
		local somethingLeft = QueryRaycast(cameraTransform.pos, leftDirection, rayDist)

		local rightDirection = TransformToParentVec(cameraTransform, {1, 0, 0})
		local somethingRight = QueryRaycast(cameraTransform.pos, rightDirection, rayDist)

		local inVehicle = GetPlayerVehicle() ~= 0
		local gPos = GetPlayerTransform().pos
		gPos[2] = gPos[2] + 0.2
		groundBelow = QueryRaycast(gPos, Vec(0, -1, 0), 0.15, 0.2)
		isTouchingGround = playerVel[2] >= -0.007 and playerVel[2] <= 0.007
		moving = not inVehicle and ((InputDown("up") and not somethingInFront) or
			(InputDown("down") and not somethingBehind) or
			InputDown("left") or InputDown("right"))
	-----

	-- Jump Logic
		if jumpTickDelay > 0 then
			jumpTickDelay = jumpTickDelay - 1
			if jumpNextFrame then
				jumpNextFrame = false
			end
		elseif jumpNextFrame then
			jumpNextFrame = false
			jumpTickDelay = 2
			playerVel[2] = 5
			SetPlayerVelocity(playerVel)
		end

		if autoBHop and InputDown("jump") and groundBelow then
			jumpNextFrame = true
			if not InputPressed("jump") and jumpTickDelay == 0 then
				playerVel[2] = 0.5 * (1 / GetTimeStep())
				SetPlayerVelocity(playerVel)
			end
		elseif InputPressed("jump") and groundBelow then
			jumpNextFrame = true
		end
	-----

	-- Speed/Strafe Logic
		if moving and moveSpeed < toWalkSpeed then
			-- Moving regularly
			moveSpeed = moveSpeed + (speedUpSpeed * GetTimeStep())
		elseif not moving and moveSpeed > 0 and (isTouchingGround or inVehicle) then
			-- Speed down while on ground/vehicle
			moveSpeed = moveSpeed - (slowDownSpeed * GetTimeStep())
			fixMoveSpeed()
		elseif moveSpeed > toWalkSpeed and isTouchingGround then
			-- Excess speed while on ground
			moveSpeed = moveSpeed - (slowDownSpeed * GetTimeStep())
			fixMoveSpeed()
		end

		local strafe = InputValue("camerax")
		if strafe ~= 0 then
			local baseStrafe = math.min(math.abs(strafe), strafeCap) * (GetTimeStep() * 25)
			moveSpeed = moveSpeed + (baseStrafe * strafeMult)
		end
	-----

	-- Slow down upon collision to avoid clipping
		if clipAvoid then
			local avoidCollision =
				somethingInFront and lastForwardMovement == 1 or
				somethingBehind and lastForwardMovement == -1 or
				somethingLeft and lastRightMovement == -1 or
				somethingRight and lastRightMovement == 1

			if avoidCollision then
				moveSpeed = moveSpeed - (slowDownSpeed * GetTimeStep())
			end
		end
	-----

	-- Movement Logic
		local forwardMovement = 0
		local rightMovement = 0

		if InputDown("up") and not somethingInFront then
			forwardMovement = forwardMovement + 1
		end

		if InputDown("down") and not somethingBehind then
			forwardMovement = forwardMovement - 1
		end

		if InputDown("left") then
			rightMovement = rightMovement - 1
		end

		if InputDown("right") then
			rightMovement = rightMovement + 1
		end

		if moving then
			lastForwardMovement = forwardMovement
			lastRightMovement = rightMovement
		else
			forwardMovement = lastForwardMovement
			rightMovement = lastRightMovement
		end

		forwardMovement = forwardMovement * moveSpeed
		rightMovement = rightMovement * moveSpeed
	-----

	-- Sound
		if enableSpeedLoop and not isTouchingGround and moveSpeed > 10 and speedLoop ~= 0 then
			local speedVolMax = 30
			local speedVol = ((math.min(moveSpeed, speedVolMax) - 10) / speedVolMax) * 0.3
			PlayLoop(speedLoop, GetPlayerTransform().pos, speedVol)
		end
	-----

	-- FoV "options.gfx.fov" int
		if enableFov then
			local fovSpeedMin = 15
			local fovSpeedMax = 60
			local fovMax = 160
			local fov = GetInt("options.gfx.fov")
			if moveSpeed > fovSpeedMin and fov < fovMax then
				local fovAmount = (moveSpeed - fovSpeedMin) / (fovSpeedMax - fovSpeedMin)
				local fovDist = (fovMax - fov) * fovAmount
				SetCameraFov(fov + fovDist)
			end
		end
	-----

	-- Apply Velocity
		local playerTransform = GetPlayerTransform()

		local forwardInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(0, 0, -1))
		local rightInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(1, 0, 0))

		local forwardDirectionStrength = VecScale(forwardInWorldSpace, forwardMovement)
		local rightDirectionStrength = VecScale(rightInWorldSpace, rightMovement)

		playerVel = VecAdd(VecAdd(playerVel, forwardDirectionStrength), rightDirectionStrength)

		SetPlayerVelocity(playerVel)
	-----
end

function draw()
	if enableDebug and GetString("game.levelid") ~= "about" then
		UiPush()
			UiAlign("top left")
			UiTranslate(20, 20)
			if string.find(GetString("game.levelid"), "hub") then
				UiTranslate(0, 40)
			end
			UiTextShadow(0, 0, 0, 0.25, 2.0)
			UiFont("bold.ttf", 50)
			UiColor(0, 0.807843137254902, 0.788235294117647, 0.75)
			UiText("Bunny Hop Mod")
			UiTranslate(0, 20)

			UiColor(1, 1, 1, 0.75)
			UiFont("regular.ttf", 20)
			UiTextShadow(0, 0, 0, 0.1, 1.0)

			UiTranslate(0, 20)
			UiText("Disabled: " .. tostring(disableMod))

			UiTranslate(0, 20)
			UiText("Move Speed: " .. moveSpeed)

			UiTranslate(0, 20)
			UiText("Ray Distance: " .. rayDist)

			UiTranslate(0, 20)
			UiText("Jump Next Frame: " .. tostring(jumpNextFrame))

			UiTranslate(0, 20)
			UiText("Jump Tick Delay: " .. jumpTickDelay)

			UiTranslate(0, 20)
			UiText("Ground Below: " .. tostring(groundBelow))

			UiTranslate(0, 20)
			UiText("Ground Touching: " .. tostring(isTouchingGround))

			UiTranslate(0, 20)
			UiText("Y Velocity: " .. GetPlayerVelocity()[2])

			UiTranslate(0, 20)
			UiText("Last Forward Movement: " .. lastForwardMovement)

			UiTranslate(0, 20)
			UiText("Last Right Movement: " .. lastRightMovement)
		UiPop()
	end

	if enableHoppometer then
		hoppometerDraw()
	end

	if showCompat then
		compatDraw()
	end
end
