local composer = require("composer")
local scene = composer.newScene()

local function gotoGameModeChoose()
    composer.gotoScene("game_mode_choose")
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
	local sceneGroup = self.view

    display.setDefault("background", 1, 1, 1)

    local name = display.newText(sceneGroup, "Corona Pong", display.contentCenterX, 80, "ObelixPro", 35)
    name:setFillColor(0, 0, 0)

    local play_button = display.newText(sceneGroup, "Play", display.contentCenterX, 200, "ObelixPro", 30)
    play_button:setFillColor(0, 0, 0)
    play_button:addEventListener("tap", gotoGameModeChoose)
end

scene:addEventListener("create", scene)

return scene
