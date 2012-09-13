
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
  var.treadmillspeed = 2
  var.accel = 1 
  var.friction = 0
  
  var.slimeaccel = .5
  var.slimefriction = .99
  
  var.hitWidth = 20
  var.hitHeight = 50
  var.clipXoffset = 3
  var.clipYoffset = 8
  var.hitYoffset = 0
  var.maxxspeed = 8
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
  var.curAnim = "blueIdle"
  


    
  
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
    corners.under = math.ceil((botPos+1 + OBJ.yspeed ) / MAP.tilewidth)
    
    
    OBJ.TL = MAP.map[corners.sideTopY][corners.left]
    OBJ.TR = MAP.map[corners.sideTopY][corners.right]
    OBJ.BL = MAP.map[corners.sideBotY][corners.left]
    OBJ.BR = MAP.map[corners.sideBotY][corners.right]
    OBJ.TC = MAP.map[corners.top][corners.centerX]
    OBJ.BC = MAP.map[corners.bottom][corners.centerX]
    OBJ.UBC = MAP.map[corners.under][corners.centerX]
    
    if OBJ.TL == nil then OBJ.TL = 1 end
    if OBJ.TR == nil then OBJ.TR = 1 end
    if OBJ.BL == nil then OBJ.BL = 1 end
    if OBJ.BR == nil then OBJ.BR = 1 end
    if OBJ.TC == nil then OBJ.TC = 1 end
    if OBJ.BC == nil then OBJ.BC = 1 end
    if OBJ.UBC == nil then OBJ.UBC = 1 end
    
    

return OBJ

end
