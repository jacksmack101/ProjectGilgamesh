CiderRunMode = {};CiderRunMode.runmode = true;CiderRunMode.assertImage = true;require "CiderDebugger";-- Project: testTiled
io.output():setvbuf('no')
system.activate("multitouch")
display.setStatusBar(display.HiddenStatusBar)
-- require controller module
local storyboard = require "storyboard"
local widget = require "widget"


local options =
{
    effect = "zoomInOut",
    time = 300,
    params = { mapToLoad = "map1" }
    }
 
storyboard.gotoScene( "playMap", options )
-- load first screen



-- Display objects added below will not respond to storyboard transitions
--[[
--require("loq_profiler").createProfiler()
local sprite = require("sprite")


system.activate("multitouch")

display.setStatusBar(display.HiddenStatusBar)

buttonVar = {};

require("mapData")
local ui = require("ui")
local uiClip = display.newGroup()

local mapClip = display.newGroup( )
local mapVar = require("testMap1")
local map = {}

     local rawMap = mapVar.layers[1].data
     local step = 1
     
     for i = 1, #rawMap do
     	if step == 1 then
     		table.insert(map, {})
     	end
    		 table.insert(map[#map], rawMap[i])
     		step = step +1
     	if step == mapVar.width+1 then
     		step = 1
     	end
     end
        
        local sheetData = require "tileSheet"
        local spriteData =sheetData.getSpriteSheetData()
        local spriteSheet = sprite.newSpriteSheetFromData( "tileSheet.png", spriteData )
        
        
        
            
        for i=1,#map do
            for j=1,#map[i] do 
                if map[i][j] == 0 then
                    
                    
                else
                    --local spriteSet = sprite.newSpriteSet(spriteSheet, map[i][j], 1)
                   -- print(map[i][j])
                    local spriteSet = sprite.newSpriteSet(spriteSheet, map[i][j], 1)
                    
                    local thisTile = sprite.newSprite(spriteSet)  
                    thisTile:setReferencePoint( display.TopLeftReferencePoint )
                    mapClip:insert(thisTile)
                    thisTile.x = math.floor(mapVar.tilewidth * (j-1))
                    thisTile.y = math.floor(mapVar.tileheight * (i -1))
                end
            end
        end
        
        ui.createButtons(uiClip, "game")  ]]--