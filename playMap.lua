----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = require "ui"
local heroFunc = require "hero"
local hero = {}
local game = {paused=false,xpos=0,ypos=0,xtarg=0,ytarg=0}
local map
local uiClip = display.newGroup()
local myText = display.newText("   ", display.contentCenterX, 0, native.systemFont, 16 )
myText:setTextColor(255, 255, 255)
local playerColor = 3
local uiDots = {}
local mapFunc = require("mapFunc")
local isWalkable = mapFunc.isWalkable 
local isSlime = mapFunc.isSlime 
local isTreadLeft = mapFunc.isTreadLeft
local isTreadRight = mapFunc.isTreadRight 
local pixelSize = 4
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
        local params = event.params
        
        --print( "MAP TO LOAD: "..params.mapToLoad ) 
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
	
	mapVar = mapFunc.buildMap(params.mapToLoad)
        hero.xpos = mapVar.playerStart.x
        hero.ypos = mapVar.playerStart.y
        hero.xtile = math.floor(hero.xpos / mapVar.tilewidth)
        hero.ytile = math.floor(hero.ypos / mapVar.tileheight)
        group:insert(mapVar.clipBack)
        group:insert(mapVar.clip)
        hero = heroFunc.createHero(hero)
        hero.gravity = mapVar.gravity
        mapVar.clip:insert(hero.group)
        group:insert(mapVar.clipFor)
        setMapPosition() 
        group:insert(uiClip)
        uiClip:insert( myText )
        local dotSize = 6
        local dotHeight = 20
        local dotWidth = 20
        local dotLeft = display.newCircle( dotWidth, dotHeight, dotSize )
        dotLeft:setFillColor(255,0,0,255)
        table.insert ( uiDots, dotLeft )
        uiClip:insert(dotLeft)
        local dotRight = display.newCircle( dotWidth*2, dotHeight, dotSize )
        dotRight:setFillColor(255,255,0,255)
        table.insert (uiDots, dotRight)
        uiClip:insert(dotRight)
        local dotJump = display.newCircle( dotWidth*3, dotHeight, dotSize )
        dotJump:setFillColor(255,0,255,255)
        table.insert (uiDots, dotJump)
        uiClip:insert(dotJump)
        local dotA1 = display.newCircle( dotWidth*4, dotHeight, dotSize )
        dotA1:setFillColor(0,255,0,255)
        table.insert (uiDots, dotA1)
        uiClip:insert(dotA1)
        local dotA2= display.newCircle( dotWidth*5, dotHeight, dotSize )
        dotA2:setFillColor(0,0,255,255)
        table.insert (uiDots, dotA2)
        uiClip:insert(dotA2)
        ui.createButtons(uiClip,{playerColor})
        group:insert( uiClip )
end


function setMapPosition()
    local mapOffset = 0
    
    mapVar.clipBack.x = display.contentCenterX - (math.round(hero.xpos/pixelSize)*pixelSize)
    mapVar.clipBack.y = display.contentCenterY - (math.round(hero.ypos/pixelSize)*pixelSize) - mapOffset
    
    mapVar.clip.x = mapVar.clipBack.x
    mapVar.clip.y = mapVar.clipBack.y
    
    mapVar.clipFor.x = mapVar.clipBack.x
    mapVar.clipFor.y = mapVar.clipBack.y
    
    
    hero.group.x = (math.round(hero.xpos/pixelSize)*pixelSize) 
    hero.group.y = (math.round(hero.ypos/pixelSize)*pixelSize)
end



---------------------------------------
-- ENTER FRAME FUNCTIONS ********************************************

local function enterFrameFunc(event)
    if not game.paused then
        local active = ui.getActive()
        local colorVar = "blue"
        myText.text = active.playerColor
        
        if active.playerColor == 1 then
            colorVar = "red"
        elseif active.playerColor == 2 then
            colorVar = "blue"
        elseif active.playerColor == 3 then
            colorVar = "yellow"
        end
        
        local clipString = colorVar..'Idle'
        if clipString ~= hero.curAnim then
            hero.clip:play(clipString)
            hero.curAnim = clipString
        end
        
        -- CHECK TO SEE IF JUMPING
        if active.up then
            uiDots[3].alpha = 1
            if not hero.jumping and not hero.dblJumped and active.jumpTap then
                if not hero.falling then
                    hero.jumping = true
                    active.jumpTap = false
                    hero.yspeed = -hero.jumpSpeed
                else
                    hero.jumping = true
                    hero.dblJumped = true
                    active.jumpTap = false
                    hero.yspeed = -(hero.jumpSpeed * .75)
                end
                
            end
            
        else
            if hero.jumping then
               if hero.yspeed < 0 then
                  hero.yspeed = hero.yspeed / 2
                  hero.jumping = false
                  hero.falling = true
               end
               
            end
            
            uiDots[3].alpha = .25
        end
        
        
        if not (active.left and active.right) then
            -- do nothing when pressing both buttons
            if active.left then
                uiDots[1].alpha = 1
                hero.dirx = -1
                hero.walking = true
            elseif active.right then
                uiDots[2].alpha = 1
                hero.dirx = 1
                hero.walking = true
            end
            
            if not active.left then
                uiDots[1].alpha = .25
            end
            if not active.right then
                uiDots[2].alpha = .25
                
            end
            if not active.left and not active.right then
                hero.walking = false
            end
            
        else
            -- reset when pressing both left and right
            uiDots[1].alpha = .25
            uiDots[2].alpha = .25
        end
        if active.action1 then
            uiDots[4].alpha = 1
        else
            uiDots[4].alpha = .25
        end
        if active.action2 then
            uiDots[5].alpha = 1
        else
            uiDots[5].alpha = .25
        end

        
        heroFunc.checkCorners(hero,mapVar)
        
        
        
       
        moveHero() 
        setMapPosition()
        
        mapFunc.cleanUpTiles(hero)
    end -- end game paused
end




function moveHero(XDIR, YDIR)
  heroFunc.checkCorners(hero,mapVar)
  
    -- TL  TR  BL  BR  TC  BC  UBC
    if hero.yspeed >= 0 or not isWalkable(hero.TC) then
        hero.jumping = false
        if not isWalkable(hero.TC) then
            --hero.ypos = hero.ypos + hero.yspeed
            hero.yspeed = 1
        end
    end
    
    if isWalkable(hero.UBC) then
      if not hero.falling and not hero.jumping then
          hero.quickfall = true
      end
      
      hero.falling = true
    else 
      hero.falling = false
      hero.dblJumped = false
    end
    
    if hero.falling then
        hero.yspeed = hero.yspeed + mapVar.gravity
        if hero.quickfall then
          hero.yspeed = hero.yspeed + (mapVar.gravity *8 )
          hero.quickfall = false
        end
        
    else
        if math.floor((hero.ypos + hero.yspeed)/mapVar.tileheight) ~= math.floor((hero.ypos)/mapVar.tileheight) then
        hero.ypos = math.floor((hero.ypos + hero.yspeed)/mapVar.tileheight)*mapVar.tileheight
        end
        while not isWalkable(hero.BC) do
        hero.ypos = hero.ypos -1 
        heroFunc.checkCorners(hero,mapVar)
        end
        hero.quickfall = false
        hero.yspeed = 0
    end
    
    if hero.yspeed > hero.maxyspeed then
        hero.yspeed = hero.maxyspeed
    end
    heroFunc.checkCorners(hero,mapVar)
    if isTreadRight(hero.UBC) then
        hero.bonusspeed = hero.treadmillspeed
    elseif isTreadLeft(hero.UBC) then
        hero.bonusspeed = -hero.treadmillspeed
    else
        hero.bonusspeed = 0
    end
    
    
    if hero.walking then
        if math.abs(hero.xspeed) < hero.maxxspeed then
            
                 hero.xspeed = hero.xspeed + (hero.slimeaccel * hero.dirx)
             else
                 hero.xspeed = hero.xspeed + (hero.accel * hero.dirx)
             end
             
             
        else
            hero.xspeed = hero.maxxspeed * hero.dirx
        
    
    end
    hero.xspeed = hero.xspeed + hero.bonusspeed
    
    if hero.walking then
        if hero.dirx == -1 and not(isWalkable(hero.TL) and isWalkable(hero.BL)) then
            hero.walking = false
            if math.floor((hero.xpos + hero.xspeed)/mapVar.tilewidth) ~= math.floor((hero.xpos)/mapVar.tilewidth) then
                hero.xpos = math.floor((hero.xpos + hero.xspeed)/mapVar.tilewidth)*mapVar.tilewidth
            end
        end
        if hero.dirx == 1  and not(isWalkable(hero.TR) and isWalkable(hero.BR))  then
            hero.walking = false
        end
    end
    
        
    
    if not hero.walking then
        if isSlime(hero.UBC) then
            hero.xspeed = hero.xspeed * hero.slimefriction
        else
            hero.xspeed = hero.xspeed * hero.friction
        end
        if math.abs(hero.xspeed) < .1 then
            hero.xspeed = 0
        end
        
     
    end
    
    
    
    hero.clip.xScale = -hero.dirx
    hero.xpos = hero.xpos + hero.xspeed
    hero.ypos = hero.ypos + hero.yspeed
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
        
        for i=1, #uiDots do
            uiDots[i].alpha = .25
        end
        
        ui.addListeners()
        Runtime:addEventListener("enterFrame", enterFrameFunc)
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
        
        Runtime:removeEventListener("enterFrame", enterFrameFunc)
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene