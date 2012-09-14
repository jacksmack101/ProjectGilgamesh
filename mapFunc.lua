module(..., package.seeall)

local mapInfo = {}
local sprite = require("sprite")
local mapClip = display.newGroup( )
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
    mapInfo.clipFor = mapClipFor
    mapInfo.data = mapData
    mapInfo.map = map
    mapInfo.tiles = mapTiles
    mapInfo.objects = rawObjects
    mapInfo.bulletList = bulletList
    

    return mapInfo
    
end


local slopes = {{46},{47},{48},{49},{76},{77},{78},{79},{50},{51},{80},{81},{999}}
-- \      /
--  \    /
--   \  /
--    \/

function setSlopePlacement(HERO)
    local tileNum = nil
    HERO.onSlope = false
    HERO.ypos = math.round(HERO.ypos)
    if not HERO.jumping then
        
    for i=1,#slopes do
        for j=1,#slopes[i] do

            if HERO.BC == slopes[i][j] then
                tileNum = i
                if i == 4 or i == 5 then
                    if not isWalkable(HERO.UBC) then
                        HERO.ypos = HERO.ypos
                    end
                end
                
            
            end

        end    
    end
    local onSlope = HERO.onSlope
    
    local xDist = (HERO.xpos) - ((HERO.centerx-1) * mapInfo.tilewidth)
    local yDist = (HERO.bottom-1) * mapInfo.tileheight
    local yGoal = HERO.ypos
    local xGoal = HERO.xpos
    if tileNum ~= nil then
       
        local divBy = 4.3 
        local divBy2 = 4
        if tileNum == 1 then
            
            
            xGoal = math.round( xDist / divBy )
            
        elseif tileNum == 2 then

                xGoal = math.round(xDist / divBy) + 8
            
        elseif tileNum == 3 then
            
                xGoal = math.round(xDist / divBy) + 16
          
        elseif tileNum == 4 then
         
                xGoal = math.round(xDist / divBy) + 24
        elseif tileNum == 5 then
            xGoal = math.floor(xDist / divBy) 
            
        elseif tileNum == 6 then
            xGoal = math.floor(xDist / divBy) + 28
            
        elseif tileNum == 7 then
            xGoal =  math.floor(xDist / divBy) + 20
            
        elseif tileNum == 8 then
            xGoal =  math.floor(xDist / divBy) + 12
            
        elseif tileNum == 9 then
            xGoal =  math.floor(xDist / divBy2) + 3
            
        elseif tileNum == 10 then
            xGoal =  math.floor(xDist / divBy2) + 18
            
        elseif tileNum == 11 then
            xGoal =  18 - math.floor(xDist / 2) 
            
        elseif tileNum == 12 then
            xGoal =   math.floor(xDist / 2)            
        end
        
                if xGoal <= 0 then
                    xGoal =1 
                end
                if xGoal >= mapInfo.tilewidth then
                    xGoal = mapInfo.tilewidth-1
                end
            yGoal = yDist + xGoal
                
                
                if yGoal <= 0 then
                    yGoal = 1
                end
            
            print ('HERO.ypos: ',HERO.ypos)
            print ('xGoal: ',xGoal)
            print ('yGoal: ',yGoal)
            print ('test: ',((math.round(HERO.ypos / mapInfo.tileheight)-1)*mapInfo.tileheight)+xGoal)
                if HERO.ypos+1 > ((math.round(HERO.ypos / mapInfo.tileheight)-1)*mapInfo.tileheight)+xGoal then
                    HERO.ypos = yGoal
                    HERO.onSlope = true
                    falling = false
                end
        
    
        
    end
    
    
    end

end



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
        if HERO.portals[1] ~= nil then
            mapClip:insert(HERO.portals[1].clip)
        end
        if HERO.portals[2] ~= nil then
            mapClip:insert(HERO.portals[2].clip)
        end
        
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


function moveBullets(MAP,GAME)
    local removeBullet = {}
    for i=1,#MAP.bulletList do
        local thisbull = bulletList[i]
        if thisbull ~= nil then
        if thisbull.type =="fireball" then
            thisbull.clip.x = bulletList[i].clip.x +bulletList[i].speed
            thisbull.tilex = math.floor(thisbull.clip.x/MAP.tilewidth)+1
            thisbull.tiley = math.floor(thisbull.clip.y/MAP.tileheight)+1
            if not isWalkable(MAP.map[thisbull.tiley][thisbull.tilex])
                or thisbull.tiley < 0
                or thisbull.tiley > #MAP.map
                or thisbull.tilex < 0
                or thisbull.tilex > #MAP.map[thisbull.tiley] 
                or thisbull.tilex < math.floor(GAME.xpos/mapInfo.tilewidth) - 8 
                or  thisbull.tilex > math.floor(GAME.xpos/mapInfo.tilewidth) + 9 
                or thisbull.tiley < math.floor(GAME.ypos/mapInfo.tileheight) - 6 
                or  thisbull.tiley > math.floor(GAME.ypos/mapInfo.tileheight) + 6  then
                
                thisbull.clip:removeSelf( )                
                table.remove (bulletList, i)
                i = i -1
            end
            
        end
        end
        
        
    end
    
    
end