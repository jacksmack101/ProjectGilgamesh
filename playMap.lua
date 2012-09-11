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

local ui = require("ui")
local uiClip = display.newGroup()
local myText = display.newText("   ", display.contentCenterX, 0, native.systemFont, 16 )
myText:setTextColor(255, 255, 255)
local playerColor = 3
local uiDots = {}
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
	
	
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

local function enterFrameFunc(event)
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