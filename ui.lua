module(..., package.seeall)

local buttonList = {}
local active = {total = 0, playerColor=0, jumpTap = false, action1Tap = false, up = false, left = false, right = false, action1 = false, action2 = false, slider = false}
local touches = {}
local colorSlider = display.newGroup( )
local colorList = {}
local colorPos = {}
local sliderMoving = false;
local sliderDistance = 70
local playerColor = nil

function getActive()
    return active
end

function setColorSlider()
    
    if playerColor == 1 then
       colorList[1].y = colorPos[2].y
       colorList[2].y = colorPos[3].y
       colorList[3].y = colorPos[1].y
       
    elseif playerColor == 2 then
       colorList[2].y = colorPos[2].y
       colorList[3].y = colorPos[3].y
       colorList[1].y = colorPos[1].y
    else
       colorList[3].y = colorPos[2].y
       colorList[1].y = colorPos[3].y
       colorList[2].y = colorPos[1].y
    end

    
    
end

function setColor1(OBJECT)
    -- set color BLUE
    OBJECT:setFillColor(228, 0, 0)
end

function setColor2(OBJECT)
    -- set color RED
    OBJECT:setFillColor(0, 0, 190)
end

function setColor3(OBJECT)
    -- set color YELLOW
    OBJECT:setFillColor(234, 234, 0)
end  

local sliderCount = 3
local sliderListener = function( obj )
        sliderCount = sliderCount - 1
        if sliderCount > 0 then
           
        else
            sliderCount = 3
            sliderMoving = false
            setColorSlider()
        end
end
local transitionTime = 200
function movePos1(OBJECT)
    -- MOVE TO TOP MOST POSTION
    transition.to( OBJECT, { time=transitionTime,y=(colorPos[1].y-colorList[1].height), onComplete=sliderListener } )
end  
 
function movePos2(OBJECT)
    -- MOVE TO TOP MOST POSTION
    
    transition.to( OBJECT, { time=transitionTime,y=(colorPos[1].y), onComplete=sliderListener } )
end  
 
function movePos3(OBJECT)
    -- MOVE TO TOP MOST POSTION
    transition.to( OBJECT, { time=transitionTime,y=(colorPos[2].y), onComplete=sliderListener } )
end  
 
function movePos4(OBJECT)
    -- MOVE TO TOP MOST POSTION
    transition.to( OBJECT, { time=transitionTime,y=(colorPos[3].y), onComplete=sliderListener } )
end          
 
function movePos5(OBJECT)
    -- MOVE TO TOP MOST POSTION
    transition.to( OBJECT, { time=transitionTime,y=(colorPos[3].y+colorList[1].height), onComplete=sliderListener } )
end  

function createButtons(GROUP, params)
    -- ADD HUD BUTTONS 

    playerColor = params[1]
    active.playerColor = playerColor
        local left = display.newImage ("leftx.png")
        left.x = 45
        left.y = 280
        buttonList.left = left
        left.touch = onTouchFunc
        GROUP:insert(left)

        local right = display.newImage ("rightx.png")
        right.x = 145
        right.y = 280        
        buttonList.right = right
        right.touch = onTouchFunc
        GROUP:insert(right)
        
        
        local up = display.newImage ("jump.png")
        up.x = 405
        up.y = 290
        buttonList.up = up
        up.touch = onTouchFunc
        GROUP:insert(up)
        

        local action1 = display.newImage ("action1.png")
        action1.x = 370
        action1.y = 230
        buttonList.action1 = action1
        action1.touch = onTouchFunc
        GROUP:insert(action1)
        

        local action2 = display.newImage ("action2.png")
        action2.x = 440
        action2.y = 230
        buttonList.action2 = action2
        action2.touch = onTouchFunc
        GROUP:insert(action2)
      
    
        --local color1 = display.newImage ("color1.png")
        local colorBack = display.newRect(display.contentWidth - 40, 20, 40, 150)
        setColor1(colorBack)
        colorBack:setReferencePoint( display.TopLeftReferencePoint )
        colorSlider:insert(colorBack)
        
        
        local color1 = display.newRect(display.contentWidth - 40, 20, 40, 50)
        setColor1(color1)
        color1:setReferencePoint( display.TopLeftReferencePoint )
        table.insert(colorPos, {x=color1.x,y=color1.y})
        table.insert ( colorList, color1 )
        colorSlider:insert(color1)
        
        local color2 = display.newRect(display.contentWidth - 40, 50, 40, 50)
        
        setColor2(color2)
        color2:setReferencePoint( display.TopLeftReferencePoint )
        color2.x = color1.x
        color2.y = color1.y + color1.height
        table.insert(colorPos, {x=color2.x,y=color2.y})
        table.insert (colorList, color2)
        colorSlider:insert(color2)
        
        local color3 = display.newRect(display.contentWidth - 40, 50, 40, 50)
        
        setColor3(color3)
        color3:setReferencePoint( display.TopLeftReferencePoint )
        color3.x = color1.x
        color3.y = color2.y + color2.height
        table.insert(colorPos, {x=color3.x,y=color3.y})
        table.insert (colorList, color3)
        colorSlider:insert(color3)
        
        
        table.insert ( colorList, colorBack )
        local mask = graphics.newMask( "sliderMask.png" )
        colorSlider:setMask( mask)        
        colorSlider.maskX = color1.x + (color1.width/2)+15
        colorSlider.maskY = color1.y + (color1.height*1.5)+3
        local slideTouch = display.newRect( color1.x-10, color1.y-10, color3.width+10, color3.height*3 +20 )
        slideTouch:setFillColor(140, 140, 140, 0)
        slideTouch.touch = onTouchFunc
        buttonList.slideTouch = slideTouch
        setColorSlider()
        GROUP:insert(colorSlider)
        
         
end


--  TOUCH EVENT LISTENER FOR MOVING FINGERS AND STUFF.
local function onTouchFunc(event)
        local leftBounds = buttonList.left.contentBounds
        local rightBounds = buttonList.right.contentBounds
        local upBounds = buttonList.up.contentBounds
        local a1Bounds = buttonList.action1.contentBounds
        local a2Bounds = buttonList.action2.contentBounds
        local slideBounds = colorSlider.contentBounds
        local targetButton = "none"
        local myNum
        for i=1, #touches do
            if event.id == touches[i][1] then
                myNum = i
            end
            
        end
        local currBound = slideBounds
        if event.x >= currBound.xMin 
            and event.x <= currBound.xMax
            and event.y >= currBound.yMin
            and event.y <= currBound.yMax then
            targetButton = 'slider'
        end
        
        local currBound = upBounds
        if event.x >= currBound.xMin 
            and event.x <= currBound.xMax
            and event.y >= currBound.yMin
            and event.y <= currBound.yMax then
            targetButton = 'up'
        end
        
        currBound = a1Bounds
        if event.x >= currBound.xMin 
            and event.x <= currBound.xMax
            and event.y >= currBound.yMin
            and event.y <= currBound.yMax then
            targetButton = 'action1'
            
        end
        
        currBound = a2Bounds
        if event.x >= currBound.xMin 
            and event.x <= currBound.xMax
            and event.y >= currBound.yMin
            and event.y <= currBound.yMax then
            targetButton = 'action2'
            
        end
        
        currBound = leftBounds
        if event.x >= currBound.xMin 
            and event.x <= currBound.xMax
            and event.y >= currBound.yMin
            and event.y <= currBound.yMax then
            targetButton = 'left'
            
        end
        
        currBound = rightBounds
        if event.x >= currBound.xMin 
            and event.x <= currBound.xMax
            and event.y >= currBound.yMin
            and event.y <= currBound.yMax then
            targetButton = 'right'    
        end
        display.getCurrentStage():setFocus(event.target)
    if event.phase == "began"  then
       table.insert ( touches, { event.id, targetButton, targetButton } )
       active[targetButton] = true
       myNum = #touches
       display.getCurrentStage():setFocus(event.target)
        if targetButton == "slider" then
           
       elseif targetButton == "up" then
           active.jumpTap = true
        
       elseif targetButton == "action1" then
           active.action1Tap = true
           
       end
    elseif event.phase == "moved" then
        if myNum == nil then
            table.insert ( touches, { event.id, targetButton, targetButton } )
            myNum = #touches
        end
        if targetButton ~= "none" then
          touches[myNum][2] = targetButton
          if touches[myNum][2] ~= touches[myNum][3] then
            active[touches[myNum][3]] = false
          end
          
          touches[myNum][3] = targetButton
      else
          touches[myNum][2] = targetButton
      end
      if touches[myNum][2] == "slider" then
        if not sliderMoving then
            if math.abs ( event.yStart - event.y ) >= sliderDistance then
                sliderMoving = true;
                
            if event.yStart > event.y then
                
                if playerColor == 1 then
                --red to blue
                movePos1(colorList[3])
                movePos2(colorList[1])
                movePos3(colorList[2])
                setColor3(colorList[4])
                playerColor = 2
                elseif playerColor == 2 then
                
                --blue to yellow
                movePos1(colorList[1])
                movePos2(colorList[2])
                movePos3(colorList[3])
                setColor1(colorList[4])
                playerColor = 3
                else

                --yellow to red
                movePos1(colorList[2])
                movePos2(colorList[3])
                movePos3(colorList[1])
                setColor2(colorList[4])
                playerColor = 1
                end
            
            else
                
                if playerColor == 1 then
                --red to yellow
                movePos3(colorList[3])
                movePos4(colorList[1])
                movePos5(colorList[2])
                setColor2(colorList[4])
                playerColor = 3
                elseif playerColor == 2 then
                
                --blue to red
                movePos3(colorList[1])
                movePos4(colorList[2])
                movePos5(colorList[3])
                setColor3(colorList[4])
                playerColor = 1
                else

                --yellow to blue
                movePos3(colorList[2])
                movePos4(colorList[3])
                movePos5(colorList[1])
                setColor1(colorList[4])
                playerColor = 2
                end
            end
            
                active.playerColor = playerColor

            end
        end
        
      end
      
      
      if touches[myNum][2] == "none" then
            active[touches[myNum][3]] = false
      else 
            active[touches[myNum][2]] = true
      end
    end
    
    
    
    if event.phase == 'ended'  or event.phase == "cancelled" then
        if targetButton == "up" then
            active.up = false
        elseif targetButton == "action1" then
            active.action1 = false
        elseif targetButton == "action2" then
            active.action2 = false
        elseif targetButton == "left" then
            active.left = false
        elseif targetButton == 'right' then
            active.right = false
        elseif targetButton == "slider" then
            
        end
        active[touches[myNum][3]] = false
        table.remove(touches, myNum )

    end
    
    
    
    
        active.total = #touches
        
        
end



function addListeners()
        buttonList.up:addEventListener( "touch", onTouchFunc )
        buttonList.action1:addEventListener( "touch", onTouchFunc )
        buttonList.action2:addEventListener( "touch", onTouchFunc )
        buttonList.left:addEventListener( "touch", onTouchFunc)
        buttonList.right:addEventListener( "touch", onTouchFunc )  
        buttonList.slideTouch:addEventListener( "touch", onTouchFunc )   
end