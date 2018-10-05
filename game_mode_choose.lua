local composer = require "composer"
local scene = composer.newScene()

local function gotoSingleplayerMode()
    options = {
        params = { game_mode = "singleplayer" }
    }
    composer.gotoScene("game", options)
end

local function gotoLocalMultiplayerMode()
    options = {
        params = { game_mode = "multiplayer" }
    }
    composer.gotoScene("game", options)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
    local sceneGroup = self.view

    display.setDefault("background", 1, 1, 1)

    local text1 = display.newText(sceneGroup, "Singleplayer", display.contentCenterX, 150, "ObelixPro", 30)
    text1:setFillColor(0, 0, 0)
    text1:addEventListener("tap", gotoSingleplayerMode)
    local text2 = display.newText(sceneGroup, "Multiplayer", display.contentCenterX, 200, "ObelixPro", 30)
    text2:setFillColor(0, 0, 0)
    text2:addEventListener("tap", gotoLocalMultiplayerMode)
end

scene:addEventListener("create", scene)

return scene
