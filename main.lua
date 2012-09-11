CiderRunMode = {};CiderRunMode.runmode = true;CiderRunMode.assertImage = true;require "CiderDebugger";

io.output():setvbuf('no')
system.activate("multitouch")
display.setStatusBar(display.HiddenStatusBar)
display.setDefault( "background", 100, 100, 100 )
require("loq_profiler").createProfiler()
-- require controller module
local storyboard = require "storyboard"
local widget = require "widget"


local options =
{
    effect = "fade",
    time = 300,
    params = { mapToLoad = "testLevel" }
    }
 
storyboard.gotoScene( "playMap", options )
-- load first screen



-- Display objects added below will not respond to storyboard transitions
