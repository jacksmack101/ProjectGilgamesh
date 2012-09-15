
module(..., package.seeall)

function createHero(params)
    local sideOffsetTop = 14
    local sideOffsetBot = 1
  local var = {}
  var.xpos = params.xpos
  var.ypos = params.ypos
  var.xtile = params.xpos
  var.ytile = params.ypos
  var.xoff = 0
  var.yoff = 0
  var.xspeed = 0
  var.yspeed = 0
  var.bonusspeed=0
  var.treadmillspeed = 3
  var.accel = 1 
  var.friction = 0
  var.slimeaccel = .2
  var.slimefriction = .99
  var.playerColor = 1
  var.hitWidth = 20
  var.hitHeight = 50
  var.clipXoffset = 3
  var.clipYoffset = 8
  var.hitYoffset = 0
  var.maxxspeed = 5
  var.maxyspeed = 20
  var.maxYwallSpeed = 2
  var.wallPause = 18
  var.jumpSpeed = 11
  var.dirx = 1
  var.diry = 1
  var.walking = false
  var.falling = false
  var.jumping = false
  var.dblJumped = false
  var.onSlope = false
  var.onslime = false
  var.ontreadmill = false
  var.porting = false
  var.checkedPortal = false
  var.curAnim = "none"
  var.portals = {}
  var.occupied = {}
  var.firespeed = 8
  var.fireReady = true
  var.firePause = 600 -- time in mili till reload fireball
  var.iceBlock = nil
  
local loqsprite = require ("loq_sprite")
local heroFactory = loqsprite.newFactory("royAnimations")
local clip = heroFactory:newSpriteGroup()
clip:setReferencePoint( display.BottomCenterReferencePoint )
var.clip = clip
  local group = display.newGroup()
  group:insert(clip)
  clip.x = clip.x - var.clipXoffset

  local dotSize = 4
  local dotAlpha = 200
    local topDot = display.newCircle( (var.hitWidth/2), 0, dotSize )
    topDot:setFillColor(255,0,0,dotAlpha)
    group:insert(topDot)
    var.topDot = topDot
    
    local botDot = display.newCircle( (var.hitWidth/2), var.hitHeight - var.hitYoffset , dotSize )
    botDot:setFillColor(0,255,0,dotAlpha)
    group:insert(botDot)
    var.botDot = botDot
    
    local topLeftDot = display.newCircle( 0, sideOffsetTop, dotSize )
    topLeftDot:setFillColor(255,255,0,dotAlpha)
    group:insert(topLeftDot)
    var.topLeftDot = topLeftDot
    
    local botLeftDot = display.newCircle( 0, (var.hitHeight - sideOffsetBot), dotSize )
    botLeftDot:setFillColor(255,255,0,dotAlpha)
    group:insert(botLeftDot)
    var.botLeftDot = botLeftDot
    
    
    local topRightDot = display.newCircle( var.hitWidth, sideOffsetTop, dotSize )
    topRightDot:setFillColor(0,255,255,dotAlpha)
    group:insert(topRightDot)
    var.topRightDot = topRightDot
    
    local botRightDot = display.newCircle( var.hitWidth, (var.hitHeight - sideOffsetBot ), dotSize )
    botRightDot:setFillColor(0,255,255,dotAlpha)
    group:insert(botRightDot)
    var.botRightDot = botRightDot
    
    group:setReferencePoint( display.BottomCenterReferencePoint )
    
    clip.y = clip.y + var.clipYoffset
  var.group = group
  return var
end



function checkCorners(OBJ,MAP)
    local corners = {}
        
    local topPos = (OBJ.ypos - OBJ.hitHeight) + OBJ.topDot.y
    local botPos = (OBJ.ypos - OBJ.hitHeight) + OBJ.botDot.y
    local centerXPos = OBJ.xpos
    local centerYPos = OBJ.ypos - (OBJ.hitHeight/2)
    local rightXPos = (OBJ.xpos - (OBJ.hitWidth/2)) + OBJ.topRightDot.x
    local leftXPos = (OBJ.xpos - (OBJ.hitWidth/2)) + OBJ.topLeftDot.x
    local sideTopY = (OBJ.ypos - OBJ.hitHeight) + OBJ.topLeftDot.y
    local sideBotY = (OBJ.ypos - OBJ.hitHeight) + OBJ.botLeftDot.y
   
   
    corners.centerX = math.ceil(centerXPos / MAP.tilewidth)
    corners.centerY = math.ceil(centerYPos / MAP.tilewidth)
    corners.left = math.ceil((leftXPos + OBJ.xspeed ) / MAP.tilewidth)
    corners.right = math.ceil((rightXPos + OBJ.xspeed ) / MAP.tilewidth)
    corners.top = math.ceil(topPos / MAP.tilewidth)
    corners.bottom = math.ceil(botPos / MAP.tilewidth)
    OBJ.centerX = corners.centerX
    OBJ.centerY = corners.centerY
    OBJ.left = corners.left
    OBJ.right = corners.right
    OBJ.top = corners.top
    
    corners.sideTopY = math.ceil(sideTopY / MAP.tilewidth)
    corners.sideBotY = math.ceil(sideBotY / MAP.tilewidth)
    corners.above = math.ceil((topPos - 1 + OBJ.yspeed ) / MAP.tilewidth)
    corners.under = math.ceil((botPos+1 + (OBJ.yspeed / 2) ) / MAP.tilewidth)
    OBJ.sideTopY = corners.sideTopY
    OBJ.sideBotY = corners.sideBotY
    OBJ.above = corners.above
    OBJ.under = corners.under

    OBJ.TL = MAP.map[corners.sideTopY][corners.left]
    OBJ.TR = MAP.map[corners.sideTopY][corners.right]
    OBJ.BL = MAP.map[corners.sideBotY][corners.left]
    OBJ.BR = MAP.map[corners.sideBotY][corners.right]
    OBJ.TC = MAP.map[corners.top][corners.centerX]
    OBJ.BC = MAP.map[corners.bottom][corners.centerX]
    OBJ.UBC = MAP.map[corners.under][corners.centerX]
    OBJ.UBL = MAP.map[corners.under][corners.left]
    OBJ.UBR = MAP.map[corners.under][corners.right]
    OBJ.centerx = corners.centerX
    OBJ.bottom = corners.bottom
    
    if OBJ.TL == nil then OBJ.TL = 1 end
    if OBJ.TR == nil then OBJ.TR = 1 end
    if OBJ.BL == nil then OBJ.BL = 1 end
    if OBJ.BR == nil then OBJ.BR = 1 end
    if OBJ.TC == nil then OBJ.TC = 1 end
    if OBJ.BC == nil then OBJ.BC = 1 end
    if OBJ.UBC == nil then OBJ.UBC = 1 end
    
    

return OBJ

end


function dropPortal(HERO,MAP,GAME)
   
    local ports = HERO.portals
    local xtile = math.floor(HERO.xpos/MAP.tilewidth)
    local ytile = math.floor((HERO.ypos-5)/MAP.tileheight)
    local okPortal = true
    --print('#HERO.occupied ',#HERO.occupied)
    for i=1 , #HERO.occupied do
        local tempT = HERO.occupied
        if tempT[i].xtile == xtile and  tempT[i].ytile == ytile then
            okPortal = false
        end
        if tempT[i].xtile - 1 == xtile and  tempT[i].ytile == ytile then
            okPortal = false
        end
        if tempT[i].xtile + 1 == xtile and  tempT[i].ytile == ytile then
            okPortal = false
        end
        if tempT[i].xtile == xtile and  tempT[i].ytile -1 == ytile then
            okPortal = false
        end
        if tempT[i].xtile +1 == xtile and  tempT[i].ytile +1 == ytile then
            okPortal = false
        end
        if tempT[i].xtile -1 == xtile and  tempT[i].ytile +1 == ytile then
            okPortal = false
        end
        if tempT[i].xtile +1 == xtile and  tempT[i].ytile -1 == ytile then
            okPortal = false
        end
        if tempT[i].xtile -1 == xtile and  tempT[i].ytile -1 == ytile then
            okPortal = false
        end
        
        
    end
        for i = 1, #HERO.portals do
            if  (xtile == HERO.portals[i].xtile 
            and ytile == HERO.portals[i].ytile) then
                okPortal = false
            
            end
        end
        
    
    if okPortal then
        local occupyTiles = {}
        if #HERO.portals == 0 then
            
            table.insert (ports, {})
            ports[#ports].xtile = xtile
            ports[#ports].ytile = ytile
            ports[#ports].ytile2 = ytile -1
            ports[#ports].x = (math.floor(HERO.xpos/MAP.tilewidth) * MAP.tilewidth)+(MAP.tilewidth/2)
            ports[#ports].y = HERO.ypos
            local portImg = display.newImage ("portal.png")
            portImg:setReferencePoint( display.BottomCenterReferencePoint )
            ports[#ports].clip = portImg
            portImg.x = ports[#ports].x
            portImg.y = ports[#ports].y - 10
            MAP.overclip:insert(portImg)
            MAP.clip:insert(MAP.overclip)
            MAP.clip:insert(HERO.group)
            
            -- drop first portal

        elseif  #HERO.portals == 1 then

            table.insert (ports, {})
            ports[#ports].xtile = xtile
            ports[#ports].ytile = ytile
            ports[#ports].ytile2 = ytile - 1
            ports[#ports].x = (math.floor(HERO.xpos/MAP.tilewidth) * MAP.tilewidth)+(MAP.tilewidth/2)
            ports[#ports].y = HERO.ypos
            local portImg = display.newImage ("portal.png")
            portImg:setReferencePoint( display.BottomCenterReferencePoint )
            ports[#ports].clip = portImg
            portImg.x = ports[#ports].x
            portImg.y = ports[#ports].y - 10
            MAP.overclip:insert(portImg)
            MAP.clip:insert(MAP.overclip)
            MAP.clip:insert(HERO.group)
            -- drop second portal
        else
            -- if both portals dropped

                local tempT = HERO.occupied
            for i=1 , #tempT do
                    if tempT[i] ~= nil then
                        if tempT[i].xtile == ports[1].xtile and  tempT[i].ytile == ports[1].ytile then
                            table.remove (HERO.occupied, i)
                            i = 1
                        elseif tempT[i].xtile == ports[1].xtile and  tempT[i].ytile == ports[1].ytile2 then
                            table.remove (HERO.occupied, i)
                            i = 1
                       --[[ elseif tempT[i].xtile == ports[2].xtile and  tempT[i].ytile == ports[2].ytile then
                            table.remove (HERO.occupied, i)
                            i = 1
                        elseif tempT[i].xtile == ports[2].xtile and  tempT[i].ytile == ports[2].ytile2 then
                            table.remove (HERO.occupied, i)
                            i = 1]]--
                        end
                        
                    end
                end

            local tempPort = ports[1].clip
            tempPort:removeSelf( )
            table.remove (ports, 1)
            table.insert (ports, {})
            ports[#ports].xtile = xtile
            ports[#ports].ytile = ytile
            ports[#ports].ytile2 = ytile -1
                ports[#ports].x = (math.floor(HERO.xpos/MAP.tilewidth) * MAP.tilewidth)+(MAP.tilewidth/2)
                ports[#ports].y = HERO.ypos
                local portImg = display.newImage ("portal.png")
                portImg:setReferencePoint( display.BottomCenterReferencePoint )
                ports[#ports].clip = portImg
                portImg.x = ports[#ports].x
                portImg.y = ports[#ports].y - 10 
            MAP.overclip:insert(portImg)
            MAP.clip:insert(MAP.overclip)
            MAP.clip:insert(HERO.group)
                -- replace oldest portal 





        end
    
        table.insert(HERO.occupied, {xtile = ports[#ports].xtile,ytile = ports[#ports].ytile} )
        table.insert(HERO.occupied, {xtile = ports[#ports].xtile,ytile = ports[#ports].ytile2} )
    
           
           
       else
           if #HERO.portals ==2 then
               
               local tempT = HERO.occupied
               local tempTrue = false
               for i=1 , #tempT do
                    if tempT[i] ~= nil then
                        if tempT[i].xtile == ports[1].xtile and  tempT[i].ytile == ports[1].ytile then
                            tempTrue = true
                        elseif tempT[i].xtile == ports[1].xtile and  tempT[i].ytile == ports[1].ytile2 then
                            tempTrue = true
                        elseif tempT[i].xtile == ports[2].xtile and  tempT[i].ytile == ports[2].ytile then
                            tempTrue = true
                        elseif tempT[i].xtile == ports[2].xtile and  tempT[i].ytile == ports[2].ytile2 then
                            tempTrue = true
                        end
                        
                    end
                end
                if tempTrue then
                    if math.abs(HERO.xpos - ports[1].x) < MAP.tilewidth*1.5 then
                        if math.abs(HERO.ypos - ports[1].y) < MAP.tileheight then
                            HERO.xpos = ports[2].x
                            HERO.ypos = ports[2].y
                            HERO.xspeed = 0
                            HERO.yspeed = 0
                            HERO.porting = true
                            GAME.xtarg = ports[2].x
                            GAME.ytarg = ports[2].y
                            GAME.paused = true
                        end
                    elseif math.abs(HERO.xpos - ports[2].x) < MAP.tilewidth*1.5 then
                        if math.abs(HERO.ypos - ports[2].y) < MAP.tileheight  then
                            HERO.xpos = ports[1].x
                            HERO.ypos = ports[1].y
                            HERO.xspeed = 0
                            HERO.yspeed = 0
                            HERO.porting = true
                            GAME.xtarg = ports[1].x
                            GAME.ytarg = ports[1].y
                            GAME.paused = true
                        end
                    end  
                    HERO.checkedPortal = false
               end
           end
           
        --print('bad portal placement')
    end
    
end

function shootFire(OBJ,MAP)
    local fireTime = OBJ.fireTime
    local function fireTime(OBJ)
        OBJ.fireReady = true
    end
    
    if OBJ.fireReady and #MAP.bulletList < 3 then
        OBJ.fireReady = false
    local myclosure = function() return fireTime( OBJ ) end
    timer.performWithDelay( OBJ.firePause, myclosure ,1 )
    
        
    local bulletList = MAP.bulletList
    table.insert (MAP.bulletList, {})
    
    local dotSize = 6
    local dotAlpha = 255
    local myNum = #bulletList
    bulletList[myNum].type = "fireball"
    bulletList[myNum].xoffset = (10 * OBJ.dirx)
    bulletList[myNum].yoffset = 18
    
    local fireBall = display.newCircle( OBJ.xpos + bulletList[myNum].xoffset, OBJ.ypos-bulletList[myNum].yoffset, dotSize )
    fireBall:setFillColor(255,0,0,dotAlpha)
    
    bulletList[myNum].clip = fireBall
    bulletList[myNum].speed = OBJ.firespeed * OBJ.dirx
    bulletList[myNum].alive = true
    MAP.overclip:insert(fireBall)
    MAP.clip:insert(MAP.overclip)
    MAP.clip:insert(OBJ.group)
end

end


function dropBlock(OBJ,MAP)
    
    local fireTime = OBJ.fireTime
    local function fireTime(OBJ)
        OBJ.fireReady = true
    end
    
    if OBJ.fireReady or OBJ.iceBlock == "none" then
        OBJ.fireReady = false
    local myclosure = function() return fireTime( OBJ ) end
    timer.performWithDelay( OBJ.firePause, myclosure ,1 )
    
    
    if OBJ.iceBlock ~= nil   then
        if OBJ.iceBlock.clip ~= nil then
          breakIceBlock(OBJ) 
         end
        
    end
    
    OBJ.iceBlock = {}
    local thisIce = OBJ.iceBlock
    
    if OBJ.dirx == 1 then
        
        if OBJ.xoff < 14 then
            thisIce.xtile = OBJ.xtile + 2
        else
            thisIce.xtile = OBJ.xtile + 3
        end
        
        
    else
        
        if OBJ.xoff < 9 then
            thisIce.xtile = OBJ.xtile - 2
        else
            thisIce.xtile = OBJ.xtile - 1
        end
    end
    thisIce.ytile = OBJ.ytile
    
    
    --local fireBall = display.newCircle( ((thisIce.xtile)*MAP.tilewidth), ((thisIce.ytile+1)*MAP.tileheight), 10 )
    --fireBall:setFillColor(255,0,0,255)
    --MAP.overclip:insert(fireBall)
    
    thisIce.tiles = {{xtile = thisIce.xtile-1,ytile =thisIce.ytile},
                     {xtile = thisIce.xtile,ytile =thisIce.ytile},
                     {xtile = thisIce.xtile-1,ytile =thisIce.ytile+1},
                     {xtile = thisIce.xtile,ytile =thisIce.ytile+1}}
    local okBlock = true
    --print('#OBJ.occupied ************************** ',#OBJ.occupied)
    for i=1 , #OBJ.occupied do
        local tempT = OBJ.occupied
        
        
        for j=1 , #thisIce.tiles do
          --[[  print('tempT[i].xtile ',tempT[i].xtile)
        print('tempT[i].ytile ',tempT[i].ytile)
        print('xtile ',thisIce.tiles[j].xtile)
        print('ytile ',thisIce.tiles[j].ytile)]]--
            if tempT[i].xtile == thisIce.tiles[j].xtile and  tempT[i].ytile == thisIce.tiles[j].ytile then
                okBlock = false
            end
        end
        
    end
    if okBlock then
    local mapF = require "mapFunc"
    if mapF.isWalkable(MAP.map[thisIce.ytile][thisIce.xtile]) and
         mapF.isWalkable(MAP.map[thisIce.ytile][thisIce.xtile+1]) and
          mapF.isWalkable(MAP.map[thisIce.ytile+1][thisIce.xtile]) and
           mapF.isWalkable(MAP.map[thisIce.ytile+1][thisIce.xtile+1]) then
           
                thisIce.xoffset = 0
                thisIce.yoffset = 4
                thisIce.xpos = ((thisIce.xtile-1) * MAP.tilewidth) + thisIce.xoffset
                thisIce.ypos = ((thisIce.ytile-1) * MAP.tilewidth) + thisIce.yoffset
                local iceImg = display.newImage ( "iceBlock.png" )
                iceImg:setReferencePoint( display.TopLeftReferencePoint )
                thisIce.clip = iceImg
                thisIce.clip.x = thisIce.xpos
                thisIce.clip.y = thisIce.ypos

                thisIce.clip = iceImg
                thisIce.xspeed = 0
                thisIce.yspeed = 0
                thisIce.alive = true
                thisIce.falling = false
                thisIce.fallCount = 0
                
                --table.insert(HERO.occupied, {xtile = ports[#ports].xtile,ytile = ports[#ports].ytile} )
                         
                    MAP.overclip:insert(thisIce.clip)
                    MAP.clip:insert(MAP.overclip)
                    MAP.clip:insert(OBJ.group)

                local myclosure = function() return fireTime( OBJ ) end
                timer.performWithDelay( OBJ.firePause, myclosure ,1 )
            else
                --print('hit test not clear')
            end

         end
    end
end

function breakIceBlock(OBJ)
    OBJ.iceBlock.clip:removeSelf( )
    OBJ.iceBlock.tiles = nil
    OBJ.iceBlock = nil
end
