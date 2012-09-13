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
    
    

    return mapInfo
    
end

function cleanUpTiles(HERO)
    if HERO.xtile ~= math.floor(HERO.xpos / mapInfo.tilewidth)
       or HERO.ytile ~= math.floor(HERO.ypos / mapInfo.tileheight)then
       HERO.xtile = math.floor(HERO.xpos / mapInfo.tilewidth)
       HERO.ytile = math.floor(HERO.ypos / mapInfo.tileheight)
       local idown = HERO.ytile - 12
       local iup = HERO.ytile + 12
       local jdown = HERO.xtile - 12
       local jup = HERO.xtile + 12
       
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
                    or j < math.floor(HERO.xpos/mapInfo.tilewidth) - 8 
                    or  j > math.floor(HERO.xpos/mapInfo.tilewidth) + 9 
                    or i < math.floor(HERO.ypos/mapInfo.tileheight) - 6 
                    or  i > math.floor(HERO.ypos/mapInfo.tileheight) + 6  then
                   
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
        mapClip:insert(HERO.group)
        end
    end
    


function isWalkable(NUM)
   local returnvar = false
   local walkable = {0}
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
   local slime = {38}
   for i=1,#slime do
    if NUM == slime[i] then
        returnvar = true
    end
   end
   
    return returnvar
    
    
    
end

function isTreadRight(NUM)
    local returnvar = false
   local slime = {38}
   for i=1,#slime do
    if NUM == slime[i] then
        returnvar = true
    end
   end
   
    return returnvar
    
    
    
end
