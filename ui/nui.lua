-- newUI by Snazzah

nUiAccent = {0.20392156862745098, 0.596078431372549, 0.8588235294117647}
nUiAccentAlt = {0.1607843137254902, 0.5019607843137255, 0.7254901960784313}
nUiCounterAccent = {1, 1, 1}
nUiPadding = 20

function nUiColorAccent(a)
	a = a or 1
	UiColor(nUiAccent[1], nUiAccent[2], nUiAccent[3], a)
end

function nUiColorAccentAlt(a)
	a = a or 1
	UiColor(nUiAccentAlt[1], nUiAccentAlt[2], nUiAccentAlt[3], a)
end

function nUiCounterColorAccent(a)
	a = a or 1
	UiColor(nUiCounterAccent[1], nUiCounterAccent[2], nUiCounterAccent[3], a)
end

function nUiHeader(text, size, wrapwidth)
	size = size or 25

	UiPush()
		UiAlign("top left")
		UiFont("MOD/assets/ui/Roboto-Black.ttf", size)
		UiColor(1, 1, 1)
		UiTextShadow(0, 0, 0, 0.5, 2.0)
		if wrapwidth ~= nil then
			UiWordWrap(wrapwidth)
		end
		local w, h = UiGetTextSize(text)
		UiText(text)
	UiPop()

	return w, h
end

function nUiTab(text, h, size, selected)
	size = size or 25
	selected = selected or false

	UiPush()
		UiAlign("top left")
		UiFont("MOD/assets/ui/Roboto-Black.ttf", size)
		UiTextShadow(0, 0, 0, 0.5, 2.0)
		local tw, th = UiGetTextSize(text)
		local w = tw + nUiPadding * 2
		local hovering = UiIsMouseInRect(w, h)
		local pressed = InputPressed("lmb")
		local clicked = hovering and pressed
		if clicked then
			UiSound('MOD/assets/ui/click.ogg')
		end

		if hovering then
			nUiColorAccentAlt()
		else
			nUiColorAccent()
		end

		if selected then
			UiRect(w, h)

			UiTranslate(nUiPadding, (h - th)/2)
			nUiCounterColorAccent()
			UiText(text)
		else
			UiTranslate(0, h - 5)
			UiRect(w, 5)

			UiTranslate(0, -(h - 5))
			UiTranslate(nUiPadding, (h - th)/2)
			if hovering then
				nUiColorAccent()
			else
				nUiCounterColorAccent()
			end
			UiText(text)
		end
	UiPop()

	return clicked, w, h
end

function nUiCheckbox(title, description, selected, wrapwidth, boxsize, textsize)
	textsize = textsize or 30
	boxsize = boxsize or 40
	selected = selected or false
	local clicked = false

	UiPush()
		UiAlign("top left")

		-- Checkbox
		UiPush()
			if selected then
				UiButtonImageBox("ui/common/box-solid-4.png", 4, 4, 0.15, 0.68, 0.38)
				UiColor(1, 1, 1)
				clicked = UiImageButton("MOD/assets/ui/check.png", boxsize, boxsize)
				btnSound = "MOD/assets/ui/off.ogg"
			else
				UiButtonImageBox("ui/common/box-solid-4.png", 4, 4)
				UiColor(1, 0.25, 0.25)
				clicked = UiBlankButton(boxsize, boxsize)
				btnSound = "MOD/assets/ui/on.ogg"
			end

			if clicked then
				UiSound(btnSound)
			end
		UiPop()

		-- Calculate heights
			local tw, th = 0, 0
			local dw, dh = 0, 0

			UiPush()
				UiFont("MOD/assets/ui/Roboto-Black.ttf", textsize)
				tw, th = UiGetTextSize(title)
			UiPop()

			if description ~= nil then
				UiPush()
					UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
					if wrapwidth ~= nil then
						UiWordWrap(wrapwidth)
					end
					dw, dh = UiGetTextSize(title)
				UiPop()
			end

			local exceedsHeight = (th + dh) > boxsize
		-----

		local w = boxsize + tw + boxsize/8
		if dw > tw then w = boxsize/8 + dw end
		local h = th + dh
		UiTranslate(boxsize + boxsize/8, 0)
		if exceedsHeight then
			UiPush()
				UiFont("MOD/assets/ui/Roboto-Black.ttf", textsize)
				UiColor(1, 1, 1)
				UiTextShadow(0, 0, 0, 0.5, 2.0)
				UiText(title)
			UiPop()

			if description ~= nil then
				UiPush()
					UiTranslate(0, th)
					UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
					UiColor(1, 1, 1, 0.5)
					UiTextShadow(0, 0, 0, 0.5, 2.0)
					if wrapwidth ~= nil then
						UiWordWrap(wrapwidth - (boxsize + boxsize/8))
					end
					UiText(description)
				UiPop()
			end
		else
			h = boxsize
			UiAlign("left middle")
			UiTranslate(0, boxsize/2)
			if description ~= nil then
				UiTranslate(0, -dh/2)
			end

			UiPush()
				UiFont("MOD/assets/ui/Roboto-Black.ttf", textsize)
				UiColor(1, 1, 1)
				UiTextShadow(0, 0, 0, 0.5, 2.0)
				UiText(title)
			UiPop()

			if description ~= nil then
				UiPush()
					UiTranslate(0, th)
					UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
					UiColor(1, 1, 1, 0.5)
					UiTextShadow(0, 0, 0, 0.5, 2.0)
					if wrapwidth ~= nil then
						UiWordWrap(wrapwidth - (boxsize + boxsize/8))
					end
					UiText(description)
				UiPop()
			end
		end
	UiPop()

	return clicked, w, h
end

function nUiRadioItem(title, description, selected, wrapwidth, boxsize, textsize)
	textsize = textsize or 30
	boxsize = boxsize or 40
	selected = selected or false
	local clicked = false

	UiPush()
		UiAlign("top left")

		-- Checkbox
		UiPush()
			local hovering = UiIsMouseInRect(boxsize, boxsize)
			if hovering then
				UiColor(0.8, 0.8, 0.8)
			else
				UiColor(1, 1, 1)
			end
			UiImageBox("MOD/assets/ui/circle.png", boxsize, boxsize)

			if selected then
				UiTranslate(boxsize/4, boxsize/4)
				if hovering then
					nUiColorAccentAlt()
				else
					nUiColorAccent()
				end
				UiImageBox("MOD/assets/ui/circle.png", boxsize/2, boxsize/2)
			end

			if InputPressed("lmb") and hovering then
				clicked = true
				UiSound('MOD/assets/ui/click.ogg')
			end
		UiPop()

		-- Calculate heights
			local tw, th = 0, 0
			local dw, dh = 0, 0

			UiPush()
				UiFont("MOD/assets/ui/Roboto-Black.ttf", textsize)
				tw, th = UiGetTextSize(title)
			UiPop()

			if description ~= nil then
				UiPush()
					UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
					if wrapwidth ~= nil then
						UiWordWrap(wrapwidth)
					end
					dw, dh = UiGetTextSize(title)
				UiPop()
			end

			local exceedsHeight = (th + dh) > boxsize
		-----

		local w = boxsize + tw + boxsize/8
		if dw > tw then w = boxsize/8 + dw end
		local h = th + dh
		UiTranslate(boxsize + boxsize/8, 0)
		if exceedsHeight then
			UiPush()
				UiFont("MOD/assets/ui/Roboto-Black.ttf", textsize)
				UiColor(1, 1, 1)
				UiTextShadow(0, 0, 0, 0.5, 2.0)
				UiText(title)
			UiPop()

			if description ~= nil then
				UiPush()
					UiTranslate(0, th)
					UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
					UiColor(1, 1, 1, 0.5)
					UiTextShadow(0, 0, 0, 0.5, 2.0)
					if wrapwidth ~= nil then
						UiWordWrap(wrapwidth - (boxsize + boxsize/8))
					end
					UiText(description)
				UiPop()
			end
		else
			h = boxsize
			UiAlign("left middle")
			UiTranslate(0, boxsize/2)
			if description ~= nil then
				UiTranslate(0, -dh/2)
			end

			UiPush()
				UiFont("MOD/assets/ui/Roboto-Black.ttf", textsize)
				UiColor(1, 1, 1)
				UiTextShadow(0, 0, 0, 0.5, 2.0)
				UiText(title)
			UiPop()

			if description ~= nil then
				UiPush()
					UiTranslate(0, th)
					UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
					UiColor(1, 1, 1, 0.5)
					UiTextShadow(0, 0, 0, 0.5, 2.0)
					if wrapwidth ~= nil then
						UiWordWrap(wrapwidth - (boxsize + boxsize/8))
					end
					UiText(description)
				UiPop()
			end
		end
	UiPop()

	return clicked, w, h
end

function nUiSlider(title, description, value, width, opts)
	width = width or 300
	value = value or 0
	local newValue = 0
	local h = 0

	opts = opts or {}
	textsize = opts.textsize or 30
	sliderimage = opts.sliderimage or "ui/common/box-solid-10.png"
	step = opts.step
	min = opts.min or 0
	max = opts.max or 1
	showX = opts.showX

	UiPush()
		UiAlign("top left")

		-- Text
			UiPush()
				UiFont("MOD/assets/ui/Roboto-Black.ttf", textsize)
				UiColor(1, 1, 1)
				UiTextShadow(0, 0, 0, 0.5, 2.0)
				local tw, th = UiGetTextSize(title)
				UiText(title)
			UiPop()

			h = h + th
			UiTranslate(0, th)
			if description ~= nil then
				UiPush()
					UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
					UiColor(1, 1, 1, 0.5)
					UiTextShadow(0, 0, 0, 0.5, 2.0)
					if wrapwidth ~= nil then
						UiWordWrap(wrapwidth - (boxsize + boxsize/8))
					end
					local dw, dh = UiGetTextSize(description)
					UiText(description)
				UiPop()
				h = h + dh
				UiTranslate(0, dh)
			end
		-----

		h = h + 5
		UiTranslate(0, 5)

		-- Slider
			local iW, iH = UiGetImageSize(sliderimage)
			h = h + iH

			-- Slider Line
			UiPush()
				local barSize = iH/5
				nUiColorAccent()
				UiTranslate(iW/2, iH/2 - barSize/2)
				-- UiRect(width, barSize)
				UiImageBox("Ui/common/box-solid-4.png", width, barSize, 4, 4)
			UiPop()

			-- Slider
			UiPush()
				nUiColorAccent()
				local sliderValue = ((value - min) / (max - min)) * width
				local newSliderValue = UiSlider(sliderimage, "x", sliderValue, 0, width)
				local slidePer = newSliderValue/width
				local newValue

				if step then
					local perNoStep = slidePer * ((max - min) / step)
					local remainder = perNoStep - math.floor(perNoStep)
					if remainder > 0.5 then
						perNoStep = math.ceil(perNoStep)
					else
						perNoStep = math.floor(perNoStep)
					end

					slidePer = math.floor(perNoStep) / (max - min)
					newValue = slidePer * width
				else
					newValue = newSliderValue
				end

				local resultValue = min + (max - min) * slidePer
			UiPop()

			-- Tooltip Text
			local decSplit = splitString(tostring(resultValue), '.')
			local valueText = decSplit[1]
			if decSplit[2] ~= nil then
				local decimals = string.sub(decSplit[2], 0, 2)
				valueText = valueText .. '.' .. decimals
			end
			if showX then
				valueText = valueText .. 'x'
			end

			-- Tooltip
			UiPush()
				UiAlign("center middle")
				UiFont("MOD/assets/ui/Roboto-Regular.ttf", textsize * 0.75)
				local ttw, tth = UiGetTextSize(valueText)
				UiTranslate(newValue + iW/2, iH + 10 + tth/2)
				nUiColorAccent()
				UiImageBox("Ui/common/box-solid-4.png", ttw + 10, tth + 10, 4, 4)
				UiColor(1, 1, 1)
				UiText(valueText)
			UiPop()
		-----
	UiPop()

	return resultValue, h
end