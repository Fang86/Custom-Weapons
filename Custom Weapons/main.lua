--Internal variables
local timer = 0 

local infAmmo = false
local infAmmoState = "Off"

local burstCount = 0
local burstMode = "auto"           -- auto = hold shoot to burst | semi = have to click for each burst EXPERIMENTAL
local burstTimer = 0

local recoilAndFlash = "Show"

local shootSound = LoadSound("sound/gun0.ogg")


local guns = {                     -- These are affected by R/F hider
  "shotgun",
  "gun",
  "rocket",
}
    
local tools = {                    -- 11 total, including any
  "any",
  "sledge",
  "spraycan",
  "extinguisher",
  "blowtorch",
  "shotgun",
  "plank",
  "pipebomb",
  "gun",
  "bomb",
  "rocket"
}

-- UI Variables
local bSpacer = 50          -- Button vertical displacement
local sSpacer = 35          -- Slider vertical displacement
local sVal = 20             -- Slider and value x displacement
local sText = -75           -- Slider text spacing
local sTextSp = -sText+150  -- Slider and text x spacing
local bWidth = 230
local bHeight = 40

-- HUD Variables
local hTextY = 15
local hTextX = 110
  

function init()
  SetInt("savegame.mod.rpm", 300)                   -- Rounds per minute
  SetInt("savegame.mod.spread", 20)                 -- 0 to 100, 0 is accurate 100 is not
  
  SetString("savegame.mod.tool", "any")             -- Default is "any" otherwise use "gun" "spraycan" etc.
  SetInt("savegame.mod.toolIndex", 1)               -- Tool index in table - any = 1
  
  SetBool("savegame.mod.drawingUI", false)

  --SetString("savegame.mod.infAmmo", "Off")
  
  SetInt("savegame.mod.ammoType", 0)                -- 0 is bullets, 1 is rockets
  SetString("savegame.mod.rocketAmmoState", "Off")

  SetString("savegame.mod.customWep", "On")         -- Whether or not the main weapon script is on (should it shoot or use normal weapons only)
  
  SetInt("savegame.mod.bulletsPer", 1)              -- Number of bullets that come out with each shot

  SetString("savegame.mod.firingMode", "Auto")      -- Auto, Semi, Burst
  
  SetInt("savegame.mod.burstCountMax", 3)           -- Bullets shot per burst
  --SetString("savegame.mod.burstMode", "auto")     -- auto = hold shoot to burst | semi = have to click for each burst (not implemented)
  SetInt("savegame.mod.burstSpeed", 600)            -- Delay between each shot in a burst, like rpm. (lower number is more delay, higher is less) 600 recommended for 3 round

  SetString("savegame.mod.hudShown", "Show")
  end

function tick(dt)
  
  if InputPressed("m") and GetBool("savegame.mod.drawingUI") == false then
		SetBool("savegame.mod.drawingUI", true)
	elseif InputPressed("m") and GetBool("savegame.mod.drawingUI") == true then
		SetBool("savegame.mod.drawingUI", false)
	end
  
  if GetBool("savegame.mod.drawingUI") == false then
    if GetString("savegame.mod.customWep") == "On" and (GetString("game.player.tool") == GetString("savegame.mod.tool") or GetString("savegame.mod.tool") == "any") and not GetBool("game.player.grabbing") then
      if not (GetString("savegame.mod.firingMode") == "Burst") then
        if timer <= 0 then
          if InputDown("lmb") and GetString("savegame.mod.firingMode") == "Auto" then        -- Fully automatic fire
            for i=1,GetInt("savegame.mod.bulletsPer") do
              shoot()
            end
            timer = 60/GetInt("savegame.mod.rpm") --rpm
          elseif InputPressed("lmb") and GetString("savegame.mod.firingMode") == "Semi" then -- Semi automatic fire
            for i=1,GetInt("savegame.mod.bulletsPer") do
              shoot()
            end
            timer = 60/GetInt("savegame.mod.rpm") --rpm
          end
        else
          timer = timer - GetTimeStep()
        end
        
      else                                                        -- If firing mode = burst
        if timer <= 0 and burstTimer <= 0 then
          if InputDown("lmb") and burstMode == "auto" then         -- Hold click to shoot bursts
            burstTimer = 0
            if burstCount < GetInt("savegame.mod.burstCountMax") then
              burst()
            else
              burstCount = 0
              timer = 60/GetInt("savegame.mod.rpm") --rpm
            end
          elseif InputPressed("lmb") and burstMode == "semi" then  -- Click to shoot a burst (does not work yet)
            burstTimer = 0
            if burstCount < GetInt("savegame.mod.burstCountMax") then
              burst()
            else
              burstCount = 0
              timer = 60/GetInt("savegame.mod.rpm") --rpm
            end
          end
        else
          timer = timer - GetTimeStep()
        end
      end
    end
  
    if burstTimer > 0 then
    burstTimer = burstTimer - GetTimeStep()
    else
      burstTimer = 60/GetInt("savegame.mod.burstSpeed")
    end
  end
end

function update()
  
end

function draw()
  if GetString("savegame.mod.hudShown") == "Show" and GetString("savegame.mod.customWep") == "On" then
    drawHud()
  end
  
  if GetBool("savegame.mod.drawingUI") == true then
    drawUI()
    UiMakeInteractive()
  end
  
  --[[UiPush()
    UiFont("font/bold.ttf", 30)
    UiTranslate(300, 300)
    UiText(getPlayerRaycastPos())
    UiTranslate(0, 30)
    UiText("")
  UiPop()]]
end

function drawHud()
  UiPush()
    UiAlign("left")
    UiColor(0,0,0)
    UiTranslate(-11, UiHeight()/4)
    --                                     w    h    Do not change from 10
    UiImageBox("common/box-solid-10.png", 125, 180, 10, 10)
    UiColor(0,.6,.8)
    UiTranslate(11, 18)
    UiFont("font/bold.ttf", 16)
    UiText("Custom Weapon")
    UiTranslate(5, 3)
    UiRect(100, 1)
    UiFont("font/bold.ttf", 14)
    
    UiTranslate(-3, hTextY)
    
    UiPush()
      UiText("Rockets: ")
      
      if GetString("savegame.mod.rocketAmmoState") == "Off" then
        UiColor(1,0,0)
      else
        UiColor(0,1,0)
      end
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetString("savegame.mod.rocketAmmoState"))
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Inf ammo: ")
      
      if infAmmoState == "Off" then
        UiColor(1,0,0)
      else
        UiColor(0,1,0)
      end
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(infAmmoState)
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Firing mode: ")
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetString("savegame.mod.firingMode"))
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("RPM: ")
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetInt("savegame.mod.rpm"))
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Spread: ")
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetInt("savegame.mod.spread"))
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Bullets/shot: ")
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetInt("savegame.mod.bulletsPer"))
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Burst speed: ")
      
      if not (GetString("savegame.mod.firingMode") == "Burst") then
        UiColor(1,0,0)
      end
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetInt("savegame.mod.burstSpeed"))
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Burst shots: ")
      
      if not (GetString("savegame.mod.firingMode") == "Burst") then
        UiColor(1,0,0)
      end
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetInt("savegame.mod.burstCountMax"))
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Recoil/Flash: ")
      
      if recoilAndFlash == "Hide" then
        UiColor(1,0,0)
      else
        UiColor(0,1,0)
      end
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(recoilAndFlash)
    UiPop()
    
    UiTranslate(0, hTextY)
    
    UiPush()
      UiText("Tool: ")
      UiAlign("right")
      UiTranslate(hTextX, 0)
      UiText(GetString("savegame.mod.tool"))
    UiPop()
    
  UiPop()
end


function drawUI()
  --UiTranslate(0, -bSpacer*10) -- x offset (pos = right, neg = left), y offset (pos = down, neg = up)
  UiColor(0,.6,.8)            -- Default color - light blue
  UiAlign("center")
  UiTranslate(UiWidth()/2, UiHeight()/4 + 50)
  UiFont("font/regular.ttf", 24)
  --UiButtonHoverColor(.5, .5, .5)
  
  UiBlur(.5)
  
  UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 1)
  
  UiPush()
    UiColor(0,0,0,.6)
    UiTranslate(0, -100)
    UiImageBox("common/box-solid-6.png", 600, 565, 6, 6)
    --UiRect(600, 500)
  UiPop()
  
  UiPush()
    UiColor(.3,.3,.3, .5)
    UiTranslate(270, -90)
    --UiButtonImageBox
    UiImageBox("common/box-solid-6.png", 35, 35, 6, 6)
  UiPop()
  
  UiPush()
    UiTranslate(0, -50)
    UiFont("font/regular.ttf", 42)
    UiText("Custom Weapons")
  UiPop()
  
  --Toggle buttons
  UiPush()
    if GetString("savegame.mod.customWep") == "On" then
      UiColor(0,1,0)
    else
      UiColor(1,0,0)
    end
    
    if UiTextButton("Custom weapon: "..GetString("savegame.mod.customWep"), bWidth, 40) then 
      if GetString("savegame.mod.customWep") == "On" then
        --customWeapon = false
        SetString("savegame.mod.customWep", "Off")
      else
        --customWeapon = true
        SetString("savegame.mod.customWep", "On")
      end
    end
  UiPop()
  
  UiTranslate(0, bSpacer)
  
  UiPush()
    if GetString("savegame.mod.rocketAmmoState") == "On" then
      UiColor(0,1,0)
    else
      UiColor(1,0,0)
    end
    
    if UiTextButton("Rocket ammo: "..GetString("savegame.mod.rocketAmmoState"), bWidth, 40) then 
      if GetInt("savegame.mod.ammoType") == 1 then
        SetInt("savegame.mod.ammoType", 0)
        SetString("savegame.mod.rocketAmmoState", "Off")
      else
        SetInt("savegame.mod.ammoType", 1)
        SetString("savegame.mod.rocketAmmoState", "On")
      end
    end
  UiPop()
  
  UiTranslate(0, bSpacer)
  
  UiPush()
    if infAmmoState == "On" then
      UiColor(0,1,0)
    else
      UiColor(1,0,0)
    end

    if UiTextButton("Infinite ammo: "..infAmmoState, bWidth, 40) then 
      if infAmmo then
        infAmmo = false
        --gUnlimited = false
        infAmmoState = "Off"
      else
        infAmmo = true
        --gUnlimited = true
        infAmmoState = "On"
        showRAF()
      end
    end
  UiPop()
  
  UiTranslate(0, bSpacer)
  
  UiPush()
    UiColor(0,.6,.8)
  
    if UiTextButton("Firing mode: "..GetString("savegame.mod.firingMode"), bWidth, 40) then 
      if GetString("savegame.mod.firingMode") == "Auto" then
        SetString("savegame.mod.firingMode", "Burst")
      elseif GetString("savegame.mod.firingMode") == "Burst" then
        SetString("savegame.mod.firingMode", "Semi")
      else
        SetString("savegame.mod.firingMode", "Auto")
      end
    end
  UiPop()
  
  UiTranslate(0, bSpacer)
  
  UiPush()
    UiTranslate(sText*1.75, 0)
    UiAlign("right")
    UiText("RPM")
    UiTranslate(sTextSp*1.4, 0)
    SetInt("savegame.mod.rpm", slider(GetInt("savegame.mod.rpm"), 10, 10000, 300))
    UiTranslate(sVal, 0)
    UiAlign("left")
    UiText(GetInt("savegame.mod.rpm"))
  UiPop()
  
  UiTranslate(0, sSpacer)
  
  UiPush()
    UiTranslate(sText*1.75, 0)
    UiAlign("right")
    UiText("Spread")
    UiTranslate(sTextSp*1.4, 0)
    SetInt("savegame.mod.spread", slider(GetInt("savegame.mod.spread"), 0, 100, 300))
    UiTranslate(sVal, 0)
    UiAlign("left")
    UiText(GetInt("savegame.mod.spread"))
  UiPop()
  
  UiTranslate(0, sSpacer)
  
  UiPush()
    UiTranslate(sText*1.75, 0)
    UiAlign("right")
    UiText("Bullets/shot")                       -- Slider label
    UiTranslate(sTextSp*1.4, 0)
    SetInt("savegame.mod.bulletsPer", slider(GetInt("savegame.mod.bulletsPer"), 0, 100, 300)) -- Set the bullets/shot to slider location starting at default
    UiTranslate(sVal, 0)
    UiAlign("left")
    UiText(GetInt("savegame.mod.bulletsPer"))                           -- Displays number of bullets/shot
  UiPop()
  
  UiTranslate(0, sSpacer)
  
  UiPush()
    if not (GetString("savegame.mod.firingMode") == "Burst") then
      UiColor(1,0,0)
    end
  
    UiTranslate(150, 0)
    UiAlign("right")
    UiText("Burst shots") 
    UiTranslate(120, 0)
    SetInt("savegame.mod.burstCountMax", slider(GetInt("savegame.mod.burstCountMax"), 2, 10, 100))
    UiTranslate(5, 0)
    UiAlign("left")
    UiText(GetInt("savegame.mod.burstCountMax"))
  UiPop()
  
  UiPush()
    if not (GetString("savegame.mod.firingMode") == "Burst") then
      UiColor(1,0,0)
    end
  
    UiTranslate(-175, 0)
    UiAlign("right")
    UiText("Burst speed")
    UiTranslate(120, 0)
    SetInt("savegame.mod.burstSpeed", slider(GetInt("savegame.mod.burstSpeed"), 60, 2000, 100))
    UiTranslate(10, 0)
    UiAlign("left")
    UiText(GetInt("savegame.mod.burstSpeed"))
  UiPop()
  
  UiTranslate(0, sSpacer)
  
  UiPush()
    --UiColor(1,1,0.7)
    UiFont("font/regular.ttf", 28)
    UiText("Other")
    UiTranslate(0, -8)
    UiPush()
      UiAlign("left")
      UiTranslate(35,0)
      UiRect(250, 3)
    UiPop()
    UiAlign("right")
    UiTranslate(-35,0)
    UiRect(250, 3)
  UiPop()
  
  UiTranslate(0, bSpacer)
  
  UiPush()
    UiPush()
    UiTranslate(-bWidth/2-5, 0)
      if recoilAndFlash == "Show" then
        UiColor(0,1,0)
      else
        UiColor(1,0,0)
      end

      if UiTextButton("Recoil/Flash: "..recoilAndFlash, bWidth, 40) then 
        if recoilAndFlash == "Show" then
          hideRAF()
        else
          showRAF()
        end
      end
    UiPop()
    
    UiTranslate(bWidth/2+5, 0)
    if GetString("savegame.mod.hudShown") == "Show" then
      UiColor(0,1,0)
    else
      UiColor(1,0,0)
    end
      
    if UiTextButton("Mod's HUD: "..GetString("savegame.mod.hudShown"), bWidth, 40) then 
      if GetString("savegame.mod.hudShown") == "Show" then
        SetString("savegame.mod.hudShown", "Hide")
      else
        SetString("savegame.mod.hudShown", "Show")
      end
    end
  UiPop()
  
  UiTranslate(0, bSpacer)
  
  UiPush()
    UiTranslate(sText, 0)
    UiAlign("right")
    UiText("Tool")
    UiTranslate(sTextSp-40, 0)
    SetInt("savegame.mod.toolIndex",  slider(GetInt("savegame.mod.toolIndex"), 1, 11, 150))
    SetString("savegame.mod.tool", tools[GetInt("savegame.mod.toolIndex")])
    UiTranslate(sVal, 0)
    UiAlign("left")
    UiText(GetString("savegame.mod.tool"))
  UiPop()
end


--Credit to "My Cresta" for this slider in his Stronk mod :)
--val = the circle location. w = width
function slider(val, min, max, w)
	UiPush()
		UiTranslate(0, -8)
		val = (val-min) / (max-min) --val = 7, min = 1, max = 100: newVal = (7-2) / (100-2) == 5/98
		UiRect(w, 3)
		UiAlign("center middle")
		UiTranslate(-w, 1)
		val = UiSlider("common/dot.png", "x", val*w, 0, w) / w
		val = math.floor(val*(max-min)+min)
	UiPop()
	return val
end

function getPlayerRaycastPos()
--[[
  local plyTransform = GetPlayerTransform()
  local fwdPos = TransformToParentPoint(plyTransform, Vec(0, 0, -300)) -- Player's position, offset by 100 facing forward

  local direction = VecSub(fwdPos, plyTransform.pos)
  local dist = VecLength(direction)
  direction = VecNormalize(direction)

  --print("PlyPos:", vec2str(plyTransform.pos), " direction: ", vec2str(direction))
  local hit, dist, normal, hs = QueryRaycast(plyTransform.pos, direction, dist)

  if hit then
      local hitPos = TransformToParentPoint(plyTransform, Vec(0, 0, dist * -1))
      --print("hit at: ", vec2str(hitPos))
      return hitPos
  end
  return TransformToParentPoint(plyTransform, Vec(0, 0, -1000000))]]
  
  --Thanks to 2crabs for this raycast code
  
  local pt = GetPlayerTransform()
	local ct = GetCameraTransform()

	local md = 500
	local f = TransformToParentPoint(ct, Vec(0, 0, md * - 1))
	local d = VecSub(f, ct.pos)
	d = VecNormalize(d)
	hit, dist, normal, hs = QueryRaycast(ct.pos, d, md)

	hb = GetShapeBody(hs)

	hbt = GetBodyTransform(hb)
	lookAt = TransformToParentPoint(ct, Vec(0, 0, dist * - 1))
  
  return lookAt
end

--[[
function getAimData(maxDist)
  local ct = GetCameraTransform()
  local forwardPos = TransformToParentPoint(ct, Vec(0, 0, -maxDist))
  local direction = VecSub(forwardPos, ct.pos)
  local distance = VecLength(direction)
  local direction = VecNormalize(direction)
  local hit, hitDistance, hitNormal, hitShape = QueryRaycast(ct.pos, direction, distance)
  if hit then
    forwardPos = TransformToParentPoint(ct, Vec(0, 0, -hitDistance))
  end
  return forwardPos, hitDistance, hitNormal, hitShape
end]]

function shoot()
  PlaySound(shootSound)

  local p = TransformToParentPoint(GetPlayerTransform(), Vec(.5, .7,  3))
  local d = VecNormalize(VecSub(getPlayerRaycastPos(), p))
  local sprd = GetInt("savegame.mod.spread")/1000 --scaled spread
  d[1] = d[1] + (math.random()-0.5)*2*sprd
  d[2] = d[2] + (math.random()-0.5)*2*sprd
  d[3] = d[3] + (math.random()-0.5)*2*sprd
  d = VecNormalize(d)
  p = VecAdd(p, VecScale(d, 5))
  --p = VecAdd(p, Vec(0, 1, 0))
  
  --p = origin d = dir, ammoType is bullet(0) or rocket(1)
  Shoot(p, d, GetInt("savegame.mod.ammoType"))	
end

function burst()
  --if burstTimer <= 0 then
    for i=1,GetInt("savegame.mod.bulletsPer") do
      shoot()
    end
    
    burstTimer = 60/GetInt("savegame.mod.burstSpeed")
    burstCount = burstCount + 1
  --end
end

function hideRAF()
  infAmmo = false
  gUnlimited = false
  infAmmoState = "Off"
  recoilAndFlash = "Hide"
  
  if GetString("savegame.mod.tool") == "any" then
    for i in pairs(guns) do
      SetInt("game.tool." .. guns[i] .. ".ammo", 0)
    end
  else
    SetInt("game.tool."..GetString("savegame.mod.tool").. ".ammo", 0)
  end
end

function showRAF()
  recoilAndFlash = "Show"
  for i in pairs(tools) do
    SetInt("game.tool." .. tools[i] .. ".ammo", 99)
  end
end