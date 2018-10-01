local composer = require("composer")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function gotoGame()
    composer.gotoScene("game")
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
    display.setDefault("background", 1, 1, 1)
    local play_button = display.newText(sceneGroup, "Play", display.contentCenterX, 200, native.systemFont, 44)
    play_button:setFillColor(0, 0, 0)
    play_button:addEventListener("tap", gotoGame)
end

scene:addEventListener("create", scene)

return scene
