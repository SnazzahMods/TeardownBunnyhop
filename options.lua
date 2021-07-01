#include "ui/nui.lua"
#include "ui/options.lua"
#include "util/index.lua"
#include "util/data.lua"
#include "util/version.lua"

function init()
	initData()
end

function nUiTitle(h)
	UiPush()
		UiAlign("middle center")
		UiTranslate(nUiPadding + 50, nUiPadding + 50)
		UiRotate(45)
		UiColor(0, 0.807843137254902, 0.788235294117647, 0.25)
		UiImageBox("MOD/assets/ui/bunny.png", 200, 200, 0, 0)
	UiPop()

	UiPush()
		UiAlign("top left")
		UiTranslate(nUiPadding, nUiPadding)
		UiFont("MOD/assets/ui/Roboto-Black.ttf", 35)
		UiTextShadow(0, 0, 0, 0.5, 2.0)
		UiColor(0, 0.807843137254902, 0.788235294117647)
		local tw, th = UiGetTextSize('Bunnyhop Mod')
		UiText('Bunnyhop Mod')

		UiFont("MOD/assets/ui/Roboto-Regular.ttf", 30)
		UiTranslate(tw + 5, 0)
		UiColor(0.5, 0.5, 0.5)
		local tw2, th2 = UiGetTextSize(modVersion)
		UiText(modVersion)

		UiTranslate(-(tw + 5), th - 5)
		UiColor(1, 1, 1)
		UiFont("MOD/assets/ui/Roboto-Italic.ttf", 25)
		UiText('by Snazzah')

		UiTranslate(-nUiPadding, -th - nUiPadding)
		nUiColorAccent()
		UiTranslate(0, h)
		local w = (nUiPadding * 2) + tw + 5 + tw2
		UiRect(w, 5)
	UiPop()

	return w
end

scrollY = 0
local scrolling = false
local scrollMouseY = 0
local scrollLastMouseY = 0
local currentTab = "main"
local tabs = {
	{"main", "General"},
	{"movement", "Movement"},
	{"hoppo", "Hoppometer"}
}

function draw()
	local innerWidth = UiWidth() - 100
	local innerHeight = UiHeight() - 120
	local scrollbarWidth = 30
	local pressed = InputPressed("lmb")

	-- Background
	UiPush()
		UiColor(1, 1, 1)
		UiImage("ui/menu/slideshow/mansion2.jpg")
	UiPop()

	-- Navigation
	UiPush()
		UiTranslate((UiWidth() - innerWidth)/2, 25)
		UiWindow(innerWidth, 100, true)
		local titleWidth = nUiTitle(100)
		UiTranslate(titleWidth, 25)

		UiPush()
			UiTranslate(0, 70)
			nUiColorAccent(0.25)
			UiRect(innerWidth - titleWidth, 5)
		UiPop()

		for i=1, #tabs do
			local id = tabs[i][1]
			local title = tabs[i][2]
			local pressed, width = nUiTab(title, 75, 40, currentTab == id)
			if pressed then
				currentTab = id
				scrollY = 0
			end
			UiTranslate(width, 0)
		end
	UiPop()

	-- Content
	UiPush()
		UiTranslate((UiWidth() - innerWidth)/2, 125)
		UiColor(0, 0, 0, 0.25)
		UiRect(innerWidth, innerHeight - 100)
		UiWindow(innerWidth, innerHeight - 100, true)

		local scrollHeight = 0
		if optionPages[currentTab] ~= nil then
			UiPush()
				UiTranslate(0, -scrollY)
				scrollHeight = optionPages[currentTab]()
			UiPop()
		end

		if scrollHeight > UiHeight() then
			local extraHeight = scrollHeight - UiHeight()
			UiTranslate(UiWidth() - scrollbarWidth, 0)

			-- Track
			UiPush()
				nUiColorAccentAlt(0.25)
				UiRect(scrollbarWidth, UiHeight())
			UiPop()

			-- Drag
			UiPush()
				local trackHover = UiIsMouseInRect(scrollbarWidth, UiHeight())
				local draggerHeight = UiHeight() * (UiHeight() / scrollHeight)
				local draggerDist = (UiHeight() - draggerHeight) / (extraHeight/scrollY)
				if scrollY == 0 then draggerDist = 0 end

				UiPush()
					UiTranslate(0, draggerDist)
					local dragHover = UiIsMouseInRect(scrollbarWidth, draggerHeight)
				UiPop()

				-- Scroll behavior
					if dragHover and pressed and not scrolling then
						local x, y = UiGetMousePos()
						scrollMouseY = y - scrollLastMouseY
						scrolling = true
						UiSound('MOD/assets/ui/click.ogg')
					elseif scrolling and InputDown("lmb") then
						local x, y = UiGetMousePos()
						local my = y - scrollMouseY
						scrollY = my / (UiHeight() - draggerHeight) * extraHeight
						scrollY = math.min(extraHeight, math.max(0, scrollY))
					elseif scrolling then
						local x, y = UiGetMousePos()
						scrollLastMouseY = math.min(UiHeight() - draggerHeight, math.max(0, y - scrollMouseY))
						scrolling = false
					end

					if trackHover and not dragHover and pressed and not scrolling then
						local x, y = UiGetMousePos()
						local my = y - draggerHeight/2
						scrollY = my / (UiHeight() - draggerHeight) * extraHeight
						scrollY = math.min(extraHeight, math.max(0, scrollY))
						scrollLastMouseY = math.min(UiHeight() - draggerHeight, math.max(0, my))
					end

					local scrollDist = -InputValue("mousewheel")
					if scrollDist ~= 0 and not scrolling then
						local scrollMovement = scrollDist * 20
						scrollY = math.min(extraHeight, math.max(0, scrollY + scrollMovement))
						scrollLastMouseY = math.min(UiHeight() - draggerHeight, math.max(0, scrollLastMouseY + scrollMovement/2))
					end
				----

				UiTranslate(0, draggerDist)
				if scrolling or dragHover then
					nUiColorAccentAlt()
				elseif trackHover then
					nUiColorAccent()
				else
					UiColor(1, 1, 1)
				end
				UiRect(scrollbarWidth, draggerHeight)
			UiPop()

			local scrollbarWidth
		end
	UiPop()

	-- Main Buttons
	UiPush()
		UiAlign("top left")
		UiTranslate((UiWidth() - innerWidth)/2, UiHeight() - 75)
		UiWindow(innerWidth, 250, true)
		UiFont("regular.ttf", 26)
		UiColor(1, 1, 1)

		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6, 1, 1, 1)
		if UiTextButton("Save and Exit", 200, 50) then
			UiSound("MOD/assets/ui/click.ogg")
			saveData()
			Menu()
		end

		UiTranslate(220, 0)
		if UiTextButton("Reset to Default", 200, 50) then
			UiSound("MOD/assets/ui/click.ogg")
			revertToDefaultData()
			applyData()
		end

		UiTranslate(220, 0)
		if UiTextButton("Cancel", 200, 50) then
			UiSound("MOD/assets/ui/click.ogg")
			Menu()
		end
	UiPop()
end