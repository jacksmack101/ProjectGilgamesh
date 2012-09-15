module(..., package.seeall)

local mapInfo = {}
local sprite = require("sprite")
local mapClip = display.newGroup( )
local mapOverClip = display.newGroup( )
local mapClipBack = display.newGroup( )
local mapClipFor = display.newGroup( )
local mapData
local map = {}
local mapBack = {}
local mapFor = {}
local mapTiles = {}
local mapTilesBack = {}
local mapTilesFor = {}
local bulletList = {}
local platforms = {}

local sheetData = require "tileSheet"
local spriteData =sheetData.getSpriteSheetData()
local spriteSheet = sprite.newSpriteSheetFromData( "tileSheet.png", spriteData )

function buildMap(NAME)
    mapData = require(NAME)

     local rawMap = mapData.layers[2].data
     local rawMapBack = mapData.layers[1].data
     local rawMapFor = mapData.layers[3].data
     local rawObjects = mapData.layers[4].objects
     mapInfo.gravity = mapData.properties.gravity
     mapInfo.tilewidth = mapData.tilewidth
     mapInfo.tileheight = mapData.tileheight
     local step = 1
     
     for i = 1, #rawMap do
     	if step == 1 then
     		table.insert(map, {})
     		table.insert(mapTiles, {})
                
     		table.insert(mapBack, {})
     		table.insert(mapTilesBack, {})
                
     		table.insert(mapFor, {})
     		table.insert(mapTilesFor, {})
     	end
    		 table.insert(map[#map], rawMap[i])
                 table.insert(mapBack[#mapBack], rawMapBack[i])
     		 table.insert(mapFor[#mapFor], rawMapFor[i])
     		step = step +1
     	if step == mapData.width+1 then
     		step = 1
     	end
     end
        
        
        for i=1,#rawObjects do
            if rawObjects[i].name == "playerStart" then
                mapInfo.playerStart = {x=rawObjects[i].x, y=rawObjects[i].y}
            end
    
        end
        
        
            
        for i=1,#map do
            for j=1,#map[i] do 
                if map[i][j] == 0 
                    or j < math.floor(mapInfo.playerStart.x/mapInfo.tilewidth) - 8 
                    or  j > math.floor(mapInfo.playerStart.x/mapInfo.tilewidth) + 10 
                    or i < math.floor(mapInfo.playerStart.y/mapInfo.tilewidth) - 8 
                    or  i > math.floor(mapInfo.playerStart.y/mapInfo.tilewidth) + 8  then
                   
                    table.insert(mapTiles[i], "none") 
                    
                else
                    local spriteSet = sprite.newSpriteSet(spriteSheet, map[i][j], 1)
                    local thisTile = sprite.newSprite(spriteSet) 
                    thisTile:play()
                    thisTile:setReferencePoint( display.TopLeftReferencePoint )
                    mapClip:insert(thisTile)
                    thisTile.x = math.floor(mapData.tilewidth * (j-1))
                    thisTile.y = math.floor(mapData.tileheight * (i -1))
                    table.insert(mapTiles[i], thisTile)
                end
                -- BACKGROUND TILES
                if mapBack[i][j] == 0 then
                   
                    table.insert(mapTilesBack[i], "none") 
                    
                else
                    local spriteSet = sprite.newSpriteSet(spriteSheet, mapBack[i][j], 1)
                    local thisTile = sprite.newSprite(spriteSet)  
                    thisTile:setReferencePoint( display.TopLeftReferencePoint )
                    mapClipBack:insert(thisTile)
                    thisTile.x = math.floor(mapData.tilewidth * (j-1))
                    thisTile.y = math.floor(mapData.tileheight * (i -1))
                    table.insert(mapTilesBack[i], thisTile)
                end
                -- FORGROUND TILES
                if mapFor[i][j] == 0 then
                   
                    table.insert(mapTilesFor[i], "none") 
                    
                else
                    local spriteSet = sprite.newSpriteSet(spriteSheet, mapFor[i][j], 1)
                    local thisTile = sprite.newSprite(spriteSet)  
                    thisTile:setReferencePoint( display.TopLeftReferencePoint )
                    mapClipFor:insert(thisTile)
                    thisTile.x = math.floor(mapData.tilewidth * (j-1))
                    thisTile.y = math.floor(mapData.tileheight * (i -1))
                    table.insert(mapTilesFor[i], thisTile)
                end
            end
        end
        
        
    
    mapInfo.clip = mapClip
    mapInfo.clipBack = mapClipBack
    mapInfo.overclip = mapOverClip
    mapInfo.clipFor = mapClipFor
    mapInfo.data = mapData
    mapInfo.map = map
    mapInfo.tiles = mapTiles
    mapInfo.objects = rawObjects
    mapInfo.bulletList = bulletList
    mapInfo.platforms = platforms
    return mapInfo
    
end


local slopes = {{46},{47},{48},{49},{76},{77},{78},{79},{50},{51},{80},{81},{999}}
-- \      /
--  \    /
--   \  /
--    \/



function cleanUpTiles(HERO, GAME)
    if GAME.xtile ~= math.floor(GAME.xpos / mapInfo.tilewidth)
       or GAME.ytile ~= math.floor(GAME.ypos / mapInfo.tileheight)then
       GAME.xtile = math.floor(GAME.xpos / mapInfo.tilewidth)
       GAME.ytile = math.floor(GAME.ypos / mapInfo.tileheight)
       local idown = GAME.ytile - 12
       local iup = GAME.ytile + 12
       local jdown = GAME.xtile - 12
       local jup = GAME.xtile + 12
       
       if idown < 1 then 
           idown = 1
       end
       if jdown < 1 then
           jdown = 1
       end
       if iup > #map then
           iup = #map 
       end
       if jup > #map[1] then
           jup = #map[1]
       end
       
    for i=idown,iup do
            for j=jdown,jup do 
                if map[i][j] == 0 
                    or j < math.floor(GAME.xpos/mapInfo.tilewidth) - 8 
                    or  j > math.floor(GAME.xpos/mapInfo.tilewidth) + 9 
                    or i < math.floor(GAME.ypos/mapInfo.tileheight) - 6 
                    or  i > math.floor(GAME.ypos/mapInfo.tileheight) + 6  then
                   
                    if mapTiles[i][j] ~= "none" then
                        local thisTile = mapTiles[i][j]
                        mapTiles[i][j] = "none"
                        thisTile:removeSelf( )
                    end
                    
                    
                else
                    if mapTiles[i][j] == "none" then
                       --print('map['..i..']['..j..']: ',map[i][j])
                        local spriteSet = sprite.newSpriteSet(spriteSheet, map[i][j], 1)
                        local thisTile = sprite.newSprite(spriteSet)  
                        thisTile:setReferencePoint( display.TopLeftReferencePoint )
                        mapClip:insert(thisTile)
                        thisTile.x = math.floor(mapData.tilewidth * (j-1))
                        thisTile.y = math.floor(mapData.tileheight * (i -1))
                        mapTiles[i][j] = thisTile
                    end
                
                end
            end
        end
        mapInfo.clip:insert(mapInfo.overclip)
        mapClip:insert(HERO.group)
        end
    end
    



function isWalkable(NUM)
   local returnvar = false
   local walkable = {0,46,47,48,49,5,51,76,77,78,79,80,81}
   for i=1,#walkable do
    if NUM == walkable[i] then
        returnvar = true
    end
   end
   
    return returnvar
end

function isSlime(NUM)
    local returnvar = false
   local slime = {38}
   for i=1,#slime do
    if NUM == slime[i] then
        returnvar = true
    end
   end
   
    return returnvar
    
    
    
end

function isTreadLeft(NUM)
    local returnvar = false
   local tiles = {52}
   for i=1,#tiles do
    if NUM == tiles[i] then
        returnvar = true
    end
   end
   
    return returnvar
    
    
    
end

function isTreadRight(NUM)
    local returnvar = false
   local tiles = {53}
   for i=1,#tiles do
    if NUM == tiles[i] then
        returnvar = true
    end
   end
   
    return returnvar
    
    
    
end


function moveBullets(MAP,GAME,HERO)
    local removeBullet = {}
    if #MAP.bulletList > 0 then
    for i=1,#MAP.bulletList do
        local thisbull = bulletList[i]
        if thisbull ~= nil then
            if thisbull.type =="fireball" then
                thisbull.clip.x = bulletList[i].clip.x +bulletList[i].speed
                thisbull.tilex = math.floor(thisbull.clip.x/MAP.tilewidth)+1
                thisbull.tiley = math.floor(thisbull.clip.y/MAP.tileheight)+1


            end
            local okBlock = true
            if HERO.iceBlock ~= nil then
                if HERO.iceBlock.clip ~= nil then
                    local thisIce =HERO.iceBlock
                    for j=1 , #HERO.iceBlock.tiles do
                        if thisbull.tilex-1 == thisIce.tiles[j].xtile and  thisbull.tiley == thisIce.tiles[j].ytile then
                            okBlock = false
                        end
                    end
                end
            end
            
            if not isWalkable(MAP.map[thisbull.tiley][thisbull.tilex])
                or thisbull.tiley < 0
                or thisbull.tiley > #MAP.map
                or thisbull.tilex < 0
                or thisbull.tilex > #MAP.map[thisbull.tiley] 
                or thisbull.tilex < math.floor(GAME.xpos/mapInfo.tilewidth) - 8 
                or  thisbull.tilex > math.floor(GAME.xpos/mapInfo.tilewidth) + 9 
                or thisbull.tiley < math.floor(GAME.ypos/mapInfo.tileheight) - 6 
                or  thisbull.tiley > math.floor(GAME.ypos/mapInfo.tileheight) + 6 
                or not okBlock then
                
                thisbull.clip:removeSelf( )                
                table.remove (bulletList, i)
                i = i -1
            end
            
        
        end
        
    end
    
    end
end


function isIceBlock(XPOS, YPOS ,HERO)
local block = false
            if HERO.iceBlock ~= nil then
                if HERO.iceBlock.clip ~= nil then
                    local thisIce =HERO.iceBlock
                    for j=1 , #HERO.iceBlock.tiles do
                        --[[print("XPOS ",XPOS )
                        print("YPOS ",YPOS )
                        print("thisIce.tiles["..j.."].xtile ",thisIce.tiles[j].xtile )
                        print("thisIce.tiles["..j.."].ytile ",thisIce.tiles[j].ytile )]]--
                        if XPOS-1 == thisIce.tiles[j].xtile and  YPOS == thisIce.tiles[j].ytile then
                            block = true
                            --print("HIT!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        end
                    end
                end
            end    
    
    return block
end

function moveIceBlock(X,HERO,MAP)
    local thisIce = HERO.iceBlock
    local okMove = false
    local Y = 0
    
    if X > 0 then
        if isWalkable(MAP.map[thisIce.tiles[2].ytile][thisIce.tiles[2].xtile + X+1])  then
            if isWalkable(MAP.map[thisIce.tiles[4].ytile][thisIce.tiles[4].xtile + X+1])  then
               okMove = true 
            end
        end    
    end
    if X < 0 then
        if isWalkable(MAP.map[thisIce.tiles[1].ytile][thisIce.tiles[1].xtile + X+1])  then
            if isWalkable(MAP.map[thisIce.tiles[3].ytile][thisIce.tiles[3].xtile + X+1])  then
               okMove = true 
               
            end
        end    
    end
    if not okMove then
        if isTreadLeft(MAP.map[thisIce.tiles[3].ytile+1][thisIce.tiles[3].xtile+1]) or
             isTreadLeft(MAP.map[thisIce.tiles[4].ytile+1][thisIce.tiles[4].xtile+1])then
            X = -1
            thisIce.ontile = "leftTread"
            okMove = true
        end
    end
    if not okMove then
        if isTreadRight(MAP.map[thisIce.tiles[3].ytile+1][thisIce.tiles[3].xtile+1]) or
             isTreadRight(MAP.map[thisIce.tiles[4].ytile+1][thisIce.tiles[4].xtile+1])then
            X = 1
            thisIce.ontile = "rightTread"
            okMove = true
        end
    end
    
    
        if isSlime(MAP.map[thisIce.tiles[3].ytile+1][thisIce.tiles[3].xtile+1]) or
             isSlime(MAP.map[thisIce.tiles[4].ytile+1][thisIce.tiles[4].xtile+1])then
             
            if thisIce.ontile == "leftTread" then
               X = -1 
               okMove = true
               thisIce.ontile = "slimeLeft"
           end
           if thisIce.ontile == "slimeLeft" then
               X = -1 
               okMove = true
               thisIce.ontile = "slimeLeft"
            end
            
            if thisIce.ontile == "rightTread" then
               X = 1 
               okMove = true
               thisIce.ontile = "slimeRight"
           end
           if thisIce.ontile == "slimeRight" then
               X = 1 
               okMove = true
               thisIce.ontile = "slimeRight"
            end
            
            
        end
    
    
        
    if not okMove then
        if isWalkable(MAP.map[thisIce.tiles[3].ytile+1][thisIce.tiles[3].xtile+1])then
            if isWalkable(MAP.map[thisIce.tiles[4].ytile+1][thisIce.tiles[4].xtile+1])then
                Y = 1
                okMove = true
            end
        end
                thisIce.ontile = "none"
    end
    
      local transTime = 300   
    if okMove and not thisIce.moving then
        local heroFunc = require "hero"
        heroFunc.checkCorners(HERO,MAP)
       if X < 0 then
           if thisIce.ontile == "slimeLeft" then
        --print('on tile',thisIce.ontile, X)
                if (isIceBlock(HERO.right+1, HERO.sideTopY ,HERO) or
                isIceBlock(HERO.right+1, HERO.sideTopY+1 ,HERO))then
                thisIce.ontile = "none"
                X = 0
                end
               
            end
        end
    
        
        
       -- print('X',X,"Y",Y)
        for j=1 , #HERO.iceBlock.tiles do
            thisIce.tiles[j].xtile = thisIce.tiles[j].xtile + X
            thisIce.tiles[j].ytile = thisIce.tiles[j].ytile + Y

        end
        thisIce.xtile = thisIce.xtile + X
        thisIce.ytile = thisIce.ytile + Y
        
        if X ~= 0 then
            thisIce.moving = true
            transition.to(thisIce.clip, {time=transTime, x=((thisIce.xtile-1) * MAP.tilewidth)})
                if isWalkable(MAP.map[thisIce.tiles[3].ytile][thisIce.tiles[3].xtile])then
                    
                if isWalkable(MAP.map[thisIce.tiles[4].ytile][thisIce.tiles[4].xtile])then
                    --print('should fall now:')
                    thisIce.falling = true
                end
                end
            else
                if thisIce.fallCount ~= nil then
                thisIce.fallCount = thisIce.fallCount+1
                end
            thisIce.moving = true
            transition.to(thisIce.clip, {time=60, y=(((thisIce.ytile-1) * MAP.tileheight)+4)})
            
            thisIce.falling = false
            if isWalkable(MAP.map[thisIce.tiles[3].ytile][thisIce.tiles[3].xtile+1])then
                if isWalkable(MAP.map[thisIce.tiles[4].ytile][thisIce.tiles[4].xtile+1])then
                    thisIce.falling = true
                end
            end
            
        
        end
    
        local function checkTime(OBJ,HERO,MAP)
           -- print('checking time!')
           -- print(OBJ.falling)
           thisIce.moving = false
            if OBJ.falling then
                moveIceBlock(0,HERO,MAP)
            end
        end
        
            
            
                if X == 0 then
                local myclosure = function() return checkTime( thisIce, HERO,MAP ) end
                timer.performWithDelay( (60 ), myclosure ,1 )
                else
                local myclosure = function() return checkTime( thisIce, HERO,MAP ) end
                timer.performWithDelay( 300+10, myclosure ,1 )
                end
             end
    
    
end
