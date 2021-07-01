local pagePad = nUiPadding * 2

clipAvoid = true
clipAvoidMult = 1
walkSpeed = 7

function pageRenderMain()
	UiTranslate(pagePad, pagePad)
	local h = pagePad

	-- Auto BHop
		local abhClicked, abhW, abhH = nUiCheckbox(
			"Auto Bunnyhop",
			"Automatically jump while holding the jump button.",
			autoBHop,
			UiWidth() - (pagePad * 2)
		)
		h = h + abhH + 30
		if abhClicked then
			autoBHop = not autoBHop
		end
		UiTranslate(0, abhH + 30)
	-----

	-- Wind SFX
		local slClicked, slW, slH = nUiCheckbox(
			"Wind SFX",
			"Gradually plays a windy loop on high speeds.",
			enableSpeedLoop,
			UiWidth() - (pagePad * 2)
		)
		h = h + slH + 30
		if abhClicked then
			enableSpeedLoop = not enableSpeedLoop
		end
		UiTranslate(0, slH + 30)
	-----

	-- FOV
		local fovClicked, fovW, fovH = nUiCheckbox(
			"Field of View Scaling",
			"Gradually increase field of view in high speeds.",
			enableFov,
			UiWidth() - (pagePad * 2)
		)
		h = h + fovH + 30
		if fovClicked then
			enableFov = not enableFov
		end
		UiTranslate(0, fovH + 30)
	-----

	-- Avoid Clipping
		local awcClicked, awcW, awcH = nUiCheckbox(
			"Avoid Wall Clipping",
			"If there is a wall in the direction of the current movement (proportial to velocity), you slow down to avoid clipping through objects.",
			clipAvoid,
			UiWidth() - (pagePad * 2)
		)
		if awcClicked then
			clipAvoid = not clipAvoid
		end
		if clipAvoid then
			UiTranslate(pagePad * 1.5, awcH + 20)
			clipAvoidMult, caH = nUiSlider("Harshness", nil, clipAvoidMult, 400,
				{
					min = 0.25,
					max = 2,
					showX = true
				}
			)

			h = h + awcH + caH + 70
			UiTranslate(-pagePad * 1.5, caH + 50)
		else
			h = h + awcH + 20
			UiTranslate(0, awcH + 20)
		end
	-----

	-- Compat
		local coClicked, coW, coH = nUiCheckbox(
			"Show Incompatible Mods",
			"Shows a list of potentially incompatible mods when starting a level.",
			showCompat,
			UiWidth() - (pagePad * 2)
		)
		if coClicked then
			showCompat = not showCompat
		end
		h = h + coH + 20
		UiTranslate(0, coH + 20)
	-----

	-- Debug
		h = h + 50
		UiTranslate(0, 50)

		local deClicked, deW, deH = nUiCheckbox(
			"Debug Info",
			"Enables the top-right overlay that displays debug information.",
			enableDebug,
			UiWidth() - (pagePad * 2)
		)
		h = h + deH + 10
		if deClicked then
			enableDebug = not enableDebug
		end
		UiTranslate(0, deH + 10)
	-----

	-- Data Version
		UiPush()
			UiAlign("top left")
			UiFont("MOD/assets/ui/Roboto-Regular.ttf", 20)
			UiColor(0.8, 0.8, 0.8)
			local dvW, dvW = UiGetTextSize('Data Version ' .. dataVersion)
			UiText('Data Version ' .. dataVersion)
		UiPop()
		h = h + dvW + 20
	-----

	return h
end

function pageRenderMovement()
	UiTranslate(pagePad, pagePad)
	local h = pagePad

	-- Move Type
		local hW, hH = nUiHeader("Movement Calculation Mode", 40)
		h = h + hH + 10
		UiTranslate(0, hH + 10)

		local moveTypes = {
			{"Simple (Legacy)", "Player direction changes velocity proportional to the player. Sudden direction changes do not impact speed."},
			{"Default", "Player direction gradually changes velocity proportinal to the world. Sudden direction changes are punished."}
		}

		UiTranslate(20, 0)
		for i=1, #moveTypes do
			local mtClicked, mtW, mtH = nUiRadioItem(
				moveTypes[i][1], moveTypes[i][2],
				moveType == i,
				UiWidth() - (pagePad * 2),
				30, 25
			)
			h = h + mtH + 10
			if mtClicked then
				moveType = i
			end
			UiTranslate(0, mtH + 10)
		end

		h = h + 20
		UiTranslate(-20, 20)
	-----

	-- Walk Speed
		local wsH
		walkSpeed, wsH = nUiSlider("Walk Speed", nil, walkSpeed, 600,
			{
				min = 5,
				max = 15,
				step = 1,
				textsize = 40,
				sliderimage = "MOD/assets/ui/slider-30.png"
			}
		)

		h = h + wsH + 70
		UiTranslate(0, wsH + 70)
	-----

	-- Strafe Mult
		local smH
		strafeMult, smH = nUiSlider("Strafe Multiplier", nil, strafeMult, 400,
			{
				min = 0,
				max = 2,
				showX = true
			}
		)

		h = h + smH + 50
		UiTranslate(0, smH + 50)
	-----

	-- Strafe Cap
		local scH
		strafeCap, scH = nUiSlider("Strafe Cap", nil, strafeCap, 400,
			{
				min = 0.01,
				max = 0.2
			}
		)

		h = h + scH + 50
		UiTranslate(0, scH + 50)
	-----

	return h
end

function pageRenderHoppo()
	UiTranslate(pagePad, pagePad)
	local h = pagePad

	local enableClicked, eW, eH = nUiCheckbox(
		"Enable Hoppometer",
		nil, enableHoppometer,
		UiWidth() - (pagePad * 2),
		60, 40
	)
	h = h + eH + 20
	if enableClicked then
		enableHoppometer = not enableHoppometer
	end
	UiTranslate(0, eH + 20)

	if enableHoppometer then
		-- Show Decimals
			local decimalClicked, dW, dH = nUiCheckbox(
				"Show Decimals",
				"Show the decimal places (eg. '.0') to the top right of the number.",
				hoppoShowDecimal,
				UiWidth() - (pagePad * 2)
			)
			h = h + dH + 10
			if decimalClicked then
				hoppoShowDecimal = not hoppoShowDecimal
			end
			UiTranslate(0, dH + 10)
		-----

		-- Hoppo combo sounds
			local csClicked, csW, csH = nUiCheckbox(
				"Enable Combo Sounds", nil,
				enableComboSound,
				UiWidth() - (pagePad * 2)
			)
			h = h + csH + 10
			if csClicked then
				enableComboSound = not enableComboSound
			end
			UiTranslate(0, csH + 10)
		-----

		-- Positions
			local hW, hH = nUiHeader("Position", 30)
			h = h + hH + 10
			UiTranslate(0, hH + 10)

			local positions = {
				"Top Left",
				"Top Right",
				"Bottom Left",
				"Bottom Right"
			}

			UiTranslate(20, 0)
			for i=1, #positions do
				local posClicked, pW, pH = nUiRadioItem(
					positions[i], nil,
					hoppoPos == i,
					UiWidth() - (pagePad * 2),
					30, 25
				)
				h = h + pH + 10
				if posClicked then
					hoppoPos = i
				end
				UiTranslate(0, pH + 10)
			end

			h = h + 20
			UiTranslate(-20, 20)
		-----

		-- Units
			local hW, hH = nUiHeader("Units", 30)
			h = h + hH + 10
			UiTranslate(0, hH + 10)

			local unitTypes = {
				"m/s", "km/h", "mph"
			}

			UiTranslate(20, 0)
			for i=1, #unitTypes do
				local unitClicked, uW, uH = nUiRadioItem(
					unitTypes[i], nil,
					hoppoUnit == i,
					UiWidth() - (pagePad * 2),
					30, 25
				)
				h = h + uH + 10
				if unitClicked then
					hoppoUnit = i
				end
				UiTranslate(0, uH + 10)
			end

			h = h + 20
			UiTranslate(-20, 20)
		-----
	end

	return h
end

optionPages = {
	main = pageRenderMain,
	movement = pageRenderMovement,
	hoppo = pageRenderHoppo
}