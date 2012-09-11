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
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
        local params = event.params
        
        --print( "MAP TO LOAD: "..params.mapToLoad ) 
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
	local mapFunc = require("mapFunc")
	mapVar = mapFunc.buildMap(params.mapToLoad)
        hero.xpos = mapVar.playerStart.x
        hero.ypos = mapVar.playerStart.y
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
    
    mapVar.clipBack.x = display.contentCenterX - hero.xpos
    mapVar.clipBack.y = display.contentCenterY - hero.ypos - mapOffset
    
    mapVar.clip.x = display.contentCenterX - hero.xpos
    mapVar.clip.y = display.contentCenterY - hero.ypos - mapOffset
    
    mapVar.clipFor.x = display.contentCenterX - hero.xpos
    mapVar.clipFor.y = display.contentCenterY - hero.ypos - mapOffset
    
    
    hero.group.x = hero.xpos 
    hero.group.y = hero.ypos
end

---------------------------------------
-- ENTER FRAME FUNCTIONS ********************************************

local function enterFrameFunc(event)
    if not game.paused then
        local active = ui.getActive()
        if active.left then
            uiDots[1].alpha = 1
        else
            uiDots[1].alpha = .25
        end


        if active.right then
            uiDots[2].alpha = 1
        else
            uiDots[2].alpha = .25
        end


        if active.up then
            uiDots[3].alpha = 1
        else
            uiDots[3].alpha = .25
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

        myText.text = active.playerColor
        heroFunc.checkCorners(hero,mapVar)
        
        if active.up then
            hero.jumping = true
            hero.yspeed = -8  
        else
            hero.jumping = false
        end
        
        if hero.UBC == 0 then
            hero.falling = true
        else
            hero.falling = false
            
        end
        
        
        if hero.falling then
            
            if hero.yspeed < hero.maxyspeed then
                hero.yspeed = math.ceil(hero.yspeed + mapVar.gravity)
            else
                hero.yspeed = hero.maxyspeed
            end
        
        else 
            if not hero.jumping then
            hero.yspeed = 0
            hero.ypos = math.floor(hero.ypos / mapVar.tileheight) * mapVar.tileheight
            end
        end
        hero.ypos = hero.ypos + hero.yspeed
        setMapPosition()
    end -- end game paused
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