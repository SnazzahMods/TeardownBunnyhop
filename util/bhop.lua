#include "index.lua"

function applyVelocity(playerVel, forwardMovement, rightMovement, rawForwardMovement, rawRightMovement, strafe)
	local playerTransform = GetPlayerTransform()

	local forwardInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(0, 0, -1))
	local rightInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(1, 0, 0))

	local forwardDirectionStrength = VecScale(forwardInWorldSpace, forwardMovement)
	local rightDirectionStrength = VecScale(rightInWorldSpace, rightMovement)

	if moveType == 1 then
		playerVel = VecAdd(VecAdd(playerVel, forwardDirectionStrength), rightDirectionStrength)
		SetPlayerVelocity(playerVel)
	elseif moveType == 2 then
		if moving or isTouchingGround and groundBelow then
			local force = VecAdd(forwardDirectionStrength, rightDirectionStrength)
			local rawForce = VecAdd(VecScale(forwardInWorldSpace, rawForwardMovement), VecScale(rightInWorldSpace, rawRightMovement))
			force[2] = GetPlayerVelocity()[2]
			currVelo[2] = GetPlayerVelocity()[2]
			local forceDeviation = VecLength(VecSub(lastRawForce, rawForce))
			local deviAmount = math.max(0, forceDeviation - math.abs(strafe))
			if not groundBelow then
				moveSpeed = moveSpeed * (1 - (deviAmount/4))
				force = VecScale(force, 1 - (deviAmount/4))
			end
			lastRawForce = rawForce
			currVelo = VecLerp(currVelo, force, 0.3)
			SetPlayerVelocity(currVelo)
		else
			currVelo[2] = GetPlayerVelocity()[2]
			SetPlayerVelocity(currVelo)
		end
	end
end