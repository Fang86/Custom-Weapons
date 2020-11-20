#include "mods.lua"

function optionsSlider(setting, def, mi, ma)
	UiColor(1,1,0.6)
	UiPush()
		UiTranslate(0, -8)
		local val = GetInt(setting)
		val = (val-mi) / (ma-mi)
		local w = 100
		UiRect(w, 3)
		UiAlign("center middle")
		val = UiSlider("common/dot.png", "x", val*w, 0, w) / w
		val = math.floor(val*(ma-mi)+mi)
		SetInt(setting, val)
	UiPop()
	return val
end

function optionsInputDesc(op, key, x1)
	UiPush()
		UiText(op)
		UiTranslate(x1,0)
		UiAlign("left")
		UiColor(0.7,0.7,0.7)
		UiText(key)
	UiPop()
	UiTranslate(0, UiFontHeight())
end


function drawOptions(scale, allowDisplayChanges)
	if scale == 0.0 then
		gOptionsShown = false
		return true 
	end

	if not gOptionsShown then
		UiSound("common/options-on.ogg")
		gOptionsShown = true
	end

	UiModalBegin()
	
	if not optionsTab then
		optionsTab = "gfx"
	end
	
	local displayMode = GetInt("options.display.mode")
	local displayResolution = GetInt("options.display.resolution")

	if not optionsCurrentDisplayMode then
		optionsCurrentDisplayMode = displayMode
		optionsCurrentDisplayResolution = displayResolution
	end
	
	local applyResolution = allowDisplayChanges and optionsTab == "display" and (displayMode ~= optionsCurrentDisplayMode or displayResolution ~= optionsCurrentDisplayResolution)
	local open = true
	UiPush()
		UiFont("font/regular.ttf", 26)

		UiColorFilter(1,1,1,scale)
		
		UiTranslate(UiCenter(), UiMiddle())
		UiAlign("center middle")
		UiScale(1, scale)
		UiWindow(600, 700)
		UiAlign("top left")

		if UiIsKeyPressed("esc") or (not UiIsMouseInRect(600, 700) and UiIsMousePressed()) then
			UiSound("common/options-off.ogg")
			open = false
		end

		UiColor(.0, .0, .0, 0.6)
		UiImageBox("common/box-solid-shadow-50.png", 600, 700, -50, -50)

		UiColor(1,1,1)		
		UiPush()
			UiFont("font/regular.ttf", 26)
			local w = 0.3
			UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.8)
			UiAlign("center middle")
			UiScale(1)
			UiTranslate(90, 40)
			local oldTab = optionsTab
			
			buttonnumber = 5
			buttonwidth = (600-80)/buttonnumber

			UiPush()
				if optionsTab == "display" then UiColor(1,1,0.7) end
				if UiTextButton("Display", buttonwidth-10, 40) then optionsTab = "display" end
			UiPop()
			UiTranslate(buttonwidth, 0)
			UiPush()
				if optionsTab == "gfx" then UiColor(1,1,0.7) end
				if UiTextButton("Graphics", buttonwidth-10, 40) then optionsTab = "gfx" end
			UiPop()
			UiTranslate(buttonwidth, 0)
			UiPush()
				if optionsTab == "audio" then UiColor(1,1,0.7) end
				if UiTextButton("Audio", buttonwidth-10, 40) then optionsTab = "audio" end
			UiPop()
			UiTranslate(buttonwidth, 0)
			UiPush()
				if optionsTab == "input" then UiColor(1,1,0.7) end
				if UiTextButton("Input", buttonwidth-10, 40) then optionsTab = "input" end
			UiPop()
			UiTranslate(buttonwidth, 0)
			UiPush()
				if optionsTab == "mods" then UiColor(1,1,0.7) end
				if UiTextButton("Mods", buttonwidth-10, 40) then optionsTab = "mods" end
			UiPop()

			if optionsTab ~= oldTab then
				UiSound("common/click.ogg")
			end
		UiPop()

		UiPush()
			
			if optionsTab == "mods" then


				if not modsTab then
					modsTab = 1
				end

				UiFont("font/regular.ttf", 26)
				local w = 0.3
				UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.8)
				UiAlign("center middle")
				UiScale(1)
				local oldTab = modsTab

				UiPush()
					local buttonnumber = #mods
					local buttonwidth = (600-40)/buttonnumber
					UiTranslate(20+buttonwidth/2, 700-40)
					for i = 1,buttonnumber,1
					do
						UiPush()
							if modsTab == i then UiColor(1,1,0.7) end
							local text = getName(i)
							if UiTextButton(text, buttonwidth-10, 40) then modsTab = i end
						UiPop()
						UiTranslate(buttonwidth, 0)
					end
				UiPop()
				if modsTab ~= oldTab then
					UiSound("common/click.ogg")
				end

				UiPush()
					local buttonnumber = 1
					local buttonwidth = (600-40)/buttonnumber
					UiTranslate(20+buttonwidth/2, 700-90)
					local text = "f"
					if getEnabled(modsTab) then
						text = "Disable"
						UiColor(1.0,0.0,0.0)
					else
						text = "Enable"
						UiColor(0.0,1.0,0.0)
					end
					if UiTextButton(text, 560, 40) then
						UiColor(1,1,1)
						toggle(modsTab)
					end
					UiColor(1,1,1)
					if getEnabled(modsTab) then
						if text ~= "Enable" then
							getUI(modsTab)
						end
					end
				UiPop()

				UiPush()
					UiTranslate(20, 120)
					UiAlign("left")
					local desc = getDesc(modsTab)
					UiText(desc)
				UiPop()
			end
			
			UiTranslate(0, 150)
			local x0 = 290
			local x1 = 20
			
			UiTranslate(x0, 0)
			UiAlign("right")

			local lh = 28
			
			if optionsTab == "display" then
				if allowDisplayChanges then
					UiText("Mode")
					UiAlign("left")
					UiTranslate(x1,0)
					if displayMode == 0 then UiColor(1,1,0.7) else UiColor(1,1,1) end
					if UiTextButton("Fullscreen") then
						SetInt("options.display.mode", 0)
					end
					UiTranslate(0, lh)
					if displayMode == 1 then UiColor(1,1,0.7) else UiColor(1,1,1) end
					if UiTextButton("Window") then
						SetInt("options.display.mode", 1)
					end
					UiTranslate(0, lh)
					if displayMode == 2 then UiColor(1,1,0.7) else UiColor(1,1,1) end
					if UiTextButton("Borderless window") then
						SetInt("options.display.mode", 2)
						SetInt("options.display.resolution", 0)
					end
					UiTranslate(0, lh)

					UiTranslate(0, lh)
					UiTranslate(-x1, 0)
					UiAlign("right")
					UiColor(1,1,1)

					UiText("Resolution")		
					UiAlign("left")
					UiTranslate(x1,0)
					if displayMode == 2 then
						local w,h = GetDisplayResolution(2, 0)
						UiColor(.8, .8, .8)
						UiText(w.."x"..h)
					else
						local c = GetDisplayResolutionCount(displayMode)
						for i=0,c-1 do
							if displayResolution==i then
								UiColor(1,1,0.7)
							else
								UiColor(1,1,1)
							end
							local w,h = GetDisplayResolution(displayMode, i)
							if UiTextButton(w.."x"..h) then
								SetInt("options.display.resolution", i)
							end
							UiTranslate(0, lh)
						end	
					end
				else
					UiAlign("center")
					UiText("Display settings are only\navailable from main menu")
				end
			end

			if optionsTab == "gfx" then
				UiPush()
					UiText("Render scale")
					UiTranslate(x1, 0)
					UiAlign("left")
					UiColor(1,1,0.7)
					local res = GetInt("options.gfx.renderscale")
					if res == 100 then
						if UiTextButton("100%") then		
							SetInt("options.gfx.renderscale", 75)
						end
					elseif res == 75 then
						if UiTextButton("75%") then		
							SetInt("options.gfx.renderscale", 50)
						end
					else
						if UiTextButton("50%") then		
							SetInt("options.gfx.renderscale", 100)
						end
					end
				UiPop()
				UiTranslate(0, lh)
				
				UiPush()
					UiText("Render quality")
					UiTranslate(x1, 0)
					UiAlign("left")
					UiColor(1,1,0.7)
					local quality = GetInt("options.gfx.quality")
					if quality == 3 then
						if UiTextButton("High") then		
							SetInt("options.gfx.quality", 1)
						end
					elseif quality == 2 then
						if UiTextButton("Medium") then		
							SetInt("options.gfx.quality", 3)
						end
					else
						if UiTextButton("Low") then		
							SetInt("options.gfx.quality", 2)
						end
					end
				UiPop()
				UiTranslate(0, lh)
				UiTranslate(0, 20)
				
				UiPush()
					UiText("Gamma correction")
					UiTranslate(x1, 0)
					UiAlign("left")
					local val = optionsSlider("options.gfx.gamma", 100, 50, 150)
					UiTranslate(120, 0)
					UiText(val/100)
				UiPop()
				UiTranslate(0, lh)

				UiPush()
					UiText("Field of view")
					UiTranslate(x1, 0)
					UiAlign("left")
					local val = optionsSlider("options.gfx.fov", 90, 60, 120)
					UiTranslate(120, 0)
					UiText(val)
				UiPop()
				UiTranslate(0, lh)

				UiPush()
					UiText("Depth of field")
					UiTranslate(x1, 0)
					UiAlign("left")
					UiColor(1,1,0.7)
					local val = GetInt("options.gfx.dof")
					if val == 1 then
						if UiTextButton("Enabled") then		
							SetInt("options.gfx.dof", 0)
						end
					else
						if UiTextButton("Disabled") then		
							SetInt("options.gfx.dof", 1)
						end
					end
				UiPop()
				UiTranslate(0, lh)
				
				UiPush()
					UiText("Barrel distortion")
					UiTranslate(x1, 0)
					UiAlign("left")
					UiColor(1,1,0.7)
					local val = GetInt("options.gfx.barrel")
					if val == 1 then
						if UiTextButton("Enabled") then		
							SetInt("options.gfx.barrel", 0)
						end
					else
						if UiTextButton("Disabled") then		
							SetInt("options.gfx.barrel", 1)
						end
					end
				UiPop()	
				UiTranslate(0, lh)
				
				UiPush()
					UiText("Motion blur")
					UiTranslate(x1, 0)
					UiAlign("left")
					UiColor(1,1,0.7)
					local val = GetInt("options.gfx.motionblur")
					if val == 1 then
						if UiTextButton("Enabled") then		
							SetInt("options.gfx.motionblur", 0)
						end
					else
						if UiTextButton("Disabled") then		
							SetInt("options.gfx.motionblur", 1)
						end
					end
				UiPop()
				UiTranslate(0, lh)
				UiTranslate(0, 20)

				UiPush()
					UiText("Vertical sync")
					UiTranslate(x1, 0)
					UiAlign("left")
					UiColor(1,1,0.7)
					local val = GetInt("options.gfx.vsync")
					if val == 1 then
						if UiTextButton("Every frame") then		
							SetInt("options.gfx.vsync", 2)
						end
					elseif val == 2 then
						if UiTextButton("Every other frame") then		
							SetInt("options.gfx.vsync", 0)
						end
					else
						if UiTextButton("Disabled") then		
							SetInt("options.gfx.vsync", 1)
						end
					end
				UiPop()
				UiTranslate(0, lh)
			end
			
			if optionsTab == "audio" then
				UiPush()
					UiText("Music volume")
					UiTranslate(x1, 0)
					UiAlign("left")
					optionsSlider("options.audio.musicvolume", 100, 0, 100)
				UiPop()
				UiTranslate(0, lh)
				UiPush()
					UiText("Sound volume")
					UiTranslate(x1, 0)
					UiAlign("left")
					optionsSlider("options.audio.soundvolume", 100, 0, 100)
				UiPop()
				UiTranslate(0, lh)
				if not GetBool("game.deploy") then
					UiPush()
						UiText("Ambience volume")
						UiTranslate(x1, 0)
						UiAlign("left")
						optionsSlider("options.audio.ambiencevolume", 100, 0, 100)
					UiPop()
					UiTranslate(0, lh)
				end
			end
			
			if optionsTab == "input" then
				UiPush()
					UiText("Sensitivity")
					UiTranslate(x1, 0)
					UiAlign("left")
					optionsSlider("options.input.sensitivity", 100, 50, 150)
				UiPop()
				UiTranslate(0, lh)

				UiPush()
					UiText("Smoothing")
					UiTranslate(x1, 0)
					UiAlign("left")
					optionsSlider("options.input.smoothing", 0, 0, 100)
				UiPop()
				UiTranslate(0, lh)

				UiPush()
					UiText("Invert look")
					UiTranslate(x1, 0)
					UiAlign("left")
					UiColor(1,1,0.7)
					local val = GetInt("options.input.invert")
					if val == 1 then
						if UiTextButton("Enabled") then		
							SetInt("options.input.invert", 0)
						end
					else
						if UiTextButton("Disabled") then		
							SetInt("options.input.invert", 1)
						end
					end
				UiPop()	
				UiTranslate(0, lh)

				UiPush()
					UiText("Head bob")
					UiTranslate(x1, 0)
					UiAlign("left")
					optionsSlider("options.input.headbob", 0, 0, 100)
				UiPop()
				UiTranslate(0, lh)
				
				UiTranslate(0, lh)

				UiPush()
					UiColor(.3, .3, .3, 0.5)
					UiAlign("center top")
					UiTranslate(10, -35)
					UiImageBox("common/box-solid-6.png", 500, 360, 6, 6)
				UiPop()
				
				UiFont("font/regular.ttf", 22)
				optionsInputDesc("Map", "Tab", x1)
				optionsInputDesc("Pause", "Esc", x1)
				UiTranslate(0, 20)
				optionsInputDesc("Move", "A S D W", x1)
				optionsInputDesc("Jump", "Spacebar", x1)
				optionsInputDesc("Crouch", "Ctrl", x1)
				optionsInputDesc("Interact", "E", x1)
				UiTranslate(0, 20)
				optionsInputDesc("Change tool", "Mouse wheel or 1-9", x1)
				optionsInputDesc("Use tool", "LMB", x1)
				optionsInputDesc("Flashlight", "F", x1)
				UiTranslate(0, 20)
				optionsInputDesc("Grab", "Hold RMB", x1)
				optionsInputDesc("Grab distance", "Hold RMB + Mouse wheel", x1)
				optionsInputDesc("Throw", "Hold RMB + LMB", x1)
			end


		UiPop()

		UiPush()
			UiTranslate(UiCenter(), UiHeight()-50)
			UiAlign("center middle")
			if applyResolution then
				UiTranslate(0,-40)
				UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.9)
				if UiTextButton("Apply display settings", 300, 40) then
					Command("game.applydisplay")
				end
			end
		UiPop()
	UiPop()

	UiModalEnd()
	
	return open
end

function clamp(value, mi, ma)
	if value < mi then value = mi end
	if value > ma then value = ma end
	return value
end