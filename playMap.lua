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
local playerColor = math.random(3)
local uiDots = {}
local mapFunc = require("mapFunc")
local isWalkable = mapFunc.isWalkable 
local isIceBlock = mapFunc.checkIceBlock
local isSlime = mapFunc.isSlime 
local isTreadLeft = mapFunc.isTreadLeft
local isTreadRight = mapFunc.isTreadRight 
local pixelSize = 2





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
        if playerColor == 1 then
            colorVar = "red"
        elseif playerColor == 2 then
            colorVar = "blue"
        elseif playerColor == 3 then
            colorVar = "yellow"
        end
        
        local clipString = colorVar..'Idle'
        if clipString ~= hero.curAnim then
            hero.clip:play(clipString)
            hero.curAnim = clipString
        end
end


function setMapPosition()
    local mapOffset = 0
    hero.group.x = (math.round(hero.xpos/pixelSize)*pixelSize) 
    hero.group.y = (math.round(hero.ypos/pixelSize)*pixelSize)
    hero.xtile = math.floor(hero.xpos / mapVar.tilewidth)
    hero.ytile = math.floor((hero.ypos-5) / mapVar.tileheight)
    hero.xoff = hero.xpos - (math.floor(hero.xpos / mapVar.tilewidth)*mapVar.tilewidth)
    hero.yoff = hero.ypos - (math.floor(hero.ypos / mapVar.tileheight)*mapVar.tileheight)
    if not game.paused then
    
        game.xpos = (math.round(hero.xpos/pixelSize)*pixelSize)
        game.ypos = (math.round(hero.ypos/pixelSize)*pixelSize)
    else
        
        if hero.porting then
            local donex = false
            local doney = false
            if math.abs(game.xtarg - game.xpos) > 1 then
                local xdist= game.xpos - game.xtarg
                game.xpos = game.xpos - (xdist/4)
            else
                donex = true
                game.xpos = (math.round(hero.xpos/pixelSize)*pixelSize)
            end
            if math.abs(game.ypos - game.ytarg) > .5 then
                local ydist= game.ypos - game.ytarg 
                game.ypos = game.ypos - (ydist/4)
                --game.ypos = (math.floor(game.ypos/pixelSize)*pixelSize)
                
                
                
            else
                doney = true
                game.ypos = (math.round(hero.ypos/pixelSize)*pixelSize)
            end
            if donex and doney then
                hero.porting = false
                game.paused = false
            end
            
               
        end

        
    end
    
    
    mapVar.clipBack.x = display.contentCenterX - game.xpos
    mapVar.clipBack.y = display.contentCenterY - game.ypos
    
    mapVar.clip.x = mapVar.clipBack.x
    mapVar.clip.y = mapVar.clipBack.y
    
    mapVar.clipFor.x = mapVar.clipBack.x
    mapVar.clipFor.y = mapVar.clipBack.y
    
    mapFunc.cleanUpTiles(hero, game)
    mapFunc.moveBullets(mapVar,game,hero)
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
            if active.playerColor == 1 then
                if active.action1Tap then
                    heroFunc.shootFire(hero,mapVar)
                    
                    active.action1Tap = false
                end
            end
            
            if active.playerColor == 2 then
                if active.action1Tap and not (hero.jumping or hero.falling or hero.ontreadmill)  then
                    if not isIceBlock(hero.centerX, hero.under ,hero) then
                        heroFunc.dropBlock(hero,mapVar)
                        mapFunc.moveIceBlock(0,hero,mapVar)
                    end
                    active.action1Tap = false
                end
            end
            
            if active.playerColor == 3 then
                if active.action1Tap and not (hero.jumping or hero.falling or hero.ontreadmill) then
                    active.action1Tap = false
                    if not isIceBlock(hero.centerX, hero.under ,hero) then
                        heroFunc.dropPortal(hero,mapVar,game)
                        
                        return
                        end
                        
                   
                
                end
            end
        
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
       -- mapFunc.setSlopePlacement(hero)
        setMapPosition()
        
        
    else -- end game paused
    setMapPosition() 
    if hero.porting then
        if not hero.checkedPortal then
        heroFunc.checkCorners(hero,mapVar)
        local x1 = hero.portals[1].xtile
        local x2 = hero.portals[2].xtile
        local y1 = hero.portals[1].ytile
        local y2 = hero.portals[2].ytile
        if isIceBlock(x1, y1 ,hero) or
            isIceBlock(x2, y2 ,hero) or
            isIceBlock(hero.centerX, hero.bottom ,hero) then
            heroFunc.breakIceBlock(hero)
        end
           hero.checkedPortal = true 
       end
       
    end
    
    end
    
        
end




function moveHero(XDIR, YDIR)

    
  heroFunc.checkCorners(hero,mapVar)
  
    -- TL  TR  BL  BR  TC  BC  UBC  or not isIceBlock(hero.centerX, hero.top ,hero)
    if hero.yspeed >= 0 or not isWalkable(hero.TC)  then
        hero.jumping = false
        if not isWalkable(hero.TC) then
            --hero.ypos = hero.ypos + hero.yspeed
            hero.yspeed = 1
        end
    end
    
        if isWalkable(hero.UBC) and not isIceBlock(hero.centerX, hero.under ,hero)  then
            if not hero.falling and not hero.jumping then
                hero.quickfall = true
            end

            hero.falling = true
        else 
            if hero.falling then
                -- print('ytile: ',hero.ytile)
            end

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
        local loopCount = 0
        while not isWalkable(hero.BC) or isIceBlock(hero.centerX, hero.bottom ,hero) do
        hero.ypos = hero.ypos -1 
        heroFunc.checkCorners(hero,mapVar)
        if loopCount > 6 then
            break
        end
        
        end
        hero.quickfall = false
        hero.yspeed = 0
        end
    
    if hero.yspeed > hero.maxyspeed then
        hero.yspeed = hero.maxyspeed
    end
    heroFunc.checkCorners(hero,mapVar)
    
    
    
    if hero.walking then
        
        if math.abs(hero.xspeed) < hero.maxxspeed then
            if isSlime(hero.UBC) then
                 hero.xspeed = hero.xspeed + (hero.slimeaccel * hero.dirx)
                -- print('onslime')
             else
                 hero.xspeed = hero.xspeed + (hero.accel * hero.dirx)
                 --print("offslime")
             end
             
             
        else
            hero.xspeed = hero.maxxspeed * hero.dirx
            
        
     end
    end
    
    
    if hero.walking then
        if hero.dirx == -1 then
            if not(isWalkable(hero.TL) and isWalkable(hero.BL)) then
                hero.walking = false
                hero.xspeed = 0
            else
               if (isIceBlock(hero.left, hero.sideTopY ,hero) or
                isIceBlock(hero.left, hero.sideTopY+1 ,hero))and
                not hero.falling and
                not hero.jumping then
                    mapFunc.moveIceBlock(-1,hero,mapVar)
                hero.walking = false
                hero.xspeed = 0
                end
            end
        end
        
        if hero.dirx == 1  then
            if not(isWalkable(hero.TR) and isWalkable(hero.BR)) then
                    hero.walking = false 
                    hero.xspeed = 0
            else
                
                if (isIceBlock(hero.right, hero.sideTopY ,hero) or
                isIceBlock(hero.right, hero.sideTopY+1 ,hero))and
                not hero.falling and
                not hero.jumping then
                    mapFunc.moveIceBlock(1,hero,mapVar)
                    hero.walking = false 
                    hero.xspeed = 0
                end
            end
        
            
        end
        
       
           
           
       
       
    end
    
        
    
    if not hero.walking then
        if isSlime(hero.UBC) then
            
            hero.xspeed = hero.xspeed * hero.slimefriction
        else
            if hero.falling or hero.jumping then
                hero.xspeed = hero.xspeed * .001
            else
                 hero.xspeed = hero.xspeed * hero.friction
             end
             
        end
        if math.abs(hero.xspeed) < .01 then
            hero.xspeed = 0
        end
        
        
     
 end 
 local pushedR = false
 local pushedL = false
 local loopCount = 0
        while not isWalkable(hero.TL) or not isWalkable(hero.BL) or
                isIceBlock(hero.left, hero.sideTopY ,hero) or
                isIceBlock(hero.left, hero.sideTopY+1 ,hero) do
            hero.xpos = hero.xpos + 1 
            heroFunc.checkCorners(hero,mapVar)
            pushedR = true
            loopCount = loopCount + 1
            if loopCount > 7 then
                loopCount = 0
                break
            end
            
        end
        while not isWalkable(hero.TR) or not isWalkable(hero.BR) or
                isIceBlock(hero.right, hero.sideTopY ,hero) or
                isIceBlock(hero.right, hero.sideTopY+1 ,hero)do
            hero.xpos = hero.xpos - 1 
            heroFunc.checkCorners(hero,mapVar)
            pushedL = true
            loopCount = loopCount + 1
            if loopCount > 7 then
                loopCount = 0
                break
            end
        end
        if pushedR then hero.xpos = hero.xpos -1 end
        if pushedL then hero.xpos = hero.xpos +1 end
 
    if isTreadRight(hero.UBC) then
        hero.bonusspeed = hero.treadmillspeed
        hero.ontreadmill = true
    elseif isTreadLeft(hero.UBC) then
        hero.bonusspeed = -hero.treadmillspeed
        hero.ontreadmill = true
    else
        hero.bonusspeed = 0
        hero.ontreadmill = false
    end
    
    if not(isWalkable(hero.TL) or not isWalkable(hero.BL)) then
        if hero.bonusspeed < 0 then
        hero.bonusspeed = 0
        end
        if hero.xspeed < 0 then
        hero.xspeed = 0
        end
    end
    if not(isWalkable(hero.TR) or not isWalkable(hero.BR)) then
        if hero.bonusspeed > 0 then
        hero.bonusspeed = 0
        end
        if hero.xspeed > 0 then
        hero.xspeed = 0
        end
    end
    
    hero.clip.xScale = -hero.dirx
    hero.xpos = hero.xpos + hero.xspeed + hero.bonusspeed
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