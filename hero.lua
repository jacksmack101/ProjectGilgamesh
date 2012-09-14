
module(..., package.seeall)

function createHero(params)
    local sideOffsetTop = 13
    local sideOffsetBot = 7
  local var = {}
  var.xpos = params.xpos
  var.ypos = params.ypos
  var.xtile = params.xpos
  var.ytile = params.ypos
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
  var.curAnim = "blueIdle"
  var.portals = {}
  var.firespeed = 8
  var.fireReady = true
  var.firePause = 600 -- time in mili till reload fireball
    
  
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
    local topDot = display.newCircle( (var.hitWidth/2), 5, dotSize )
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
    
    
    corners.sideTopY = math.ceil(sideTopY / MAP.tilewidth)
    corners.sideBotY = math.ceil(sideBotY / MAP.tilewidth)
    corners.above = math.ceil((topPos - 1 + OBJ.yspeed ) / MAP.tilewidth)
    corners.under = math.ceil((botPos+1 + (OBJ.yspeed / 2) ) / MAP.tilewidth)
    
    
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
    print('fire portal')
    local ports = HERO.portals
    if #HERO.portals == 0 then
        print( 'first portal' )
        table.insert (ports, {})
        ports[#ports].x = (math.floor(HERO.xpos/MAP.tilewidth) * MAP.tilewidth)+(MAP.tilewidth/2)
        ports[#ports].y = HERO.ypos
        local portImg = display.newImage ("portal.png")
        portImg:setReferencePoint( display.BottomCenterReferencePoint )
        ports[#ports].clip = portImg
        portImg.x = ports[#ports].x
        portImg.y = ports[#ports].y - 10
        MAP.clip:insert(portImg)
        MAP.clip:insert(HERO.group)
        -- drop first portal
        
    elseif  #HERO.portals == 1 then
        
        table.insert (ports, {})
        ports[#ports].x = (math.floor(HERO.xpos/MAP.tilewidth) * MAP.tilewidth)+(MAP.tilewidth/2)
        ports[#ports].y = HERO.ypos
        local portImg = display.newImage ("portal.png")
        portImg:setReferencePoint( display.BottomCenterReferencePoint )
        ports[#ports].clip = portImg
        portImg.x = ports[#ports].x
        portImg.y = ports[#ports].y - 10
        MAP.clip:insert(portImg)
        MAP.clip:insert(HERO.group)
        -- drop second portal
    else
        -- if both portals dropped
        if math.abs(HERO.xpos - ports[1].x) < MAP.tilewidth*1.5 then
            if math.abs(HERO.ypos - ports[1].y) < MAP.tileheight*1.5 then
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
            if math.abs(HERO.ypos - ports[2].y) < MAP.tileheight*1.5 then
                HERO.xpos = ports[1].x
                HERO.ypos = ports[1].y
                HERO.xspeed = 0
                HERO.yspeed = 0
                HERO.porting = true
                GAME.xtarg = ports[1].x
                GAME.ytarg = ports[1].y
                GAME.paused = true
            end
        else
           
           local tempPort = ports[1].clip
           tempPort:removeSelf( )
           table.remove (ports, 1)
            table.insert (ports, {})
            ports[#ports].x = (math.floor(HERO.xpos/MAP.tilewidth) * MAP.tilewidth)+(MAP.tilewidth/2)
            ports[#ports].y = HERO.ypos
            local portImg = display.newImage ("portal.png")
            portImg:setReferencePoint( display.BottomCenterReferencePoint )
            ports[#ports].clip = portImg
            portImg.x = ports[#ports].x
            portImg.y = ports[#ports].y - 10 
            MAP.clip:insert(portImg)
            MAP.clip:insert(HERO.group)
            -- replace oldest portal 
        end
        
        
        
        -- if standing in 3 block radius of portal use it
        
        
        -- if not near a portal drop new portal and destroy oldest portal
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
    MAP.clip:insert(fireBall)
end

end
