local composer = require("composer")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
    system.activate("multitouch")

	local game_mode = event.params.game_mode

	local maxWidth = display.contentWidth
    local maxHeight = display.safeActualContentHeight

    local physics = require("physics")
    physics.start()
    physics.setGravity(0, 0) -- выключаем гравитацию

    display.setDefault("background", 1, 1, 1)

    -- делаем стены статическими телами, чтобы мячик от них отбивался
    local left_wall = display.newRect(0, display.contentCenterY, 10, maxHeight)
    physics.addBody(left_wall, "static")
    local right_wall = display.newRect(maxWidth, display.contentCenterY, 10, maxHeight)
    physics.addBody(right_wall, "static")

    -- создаём ракетки
	local top_racket = display.newRoundedRect(display.contentCenterX, 0, 60, 20, 15)
	physics.addBody(top_racket, "static")
	top_racket:setFillColor(0)
	local bottom_racket = display.newRoundedRect(display.contentCenterX, maxHeight - 85, 60, 20, 15)
	physics.addBody(bottom_racket, "static")
	bottom_racket:setFillColor(0)

	if game_mode == "multiplayer" then
	    player1_racket = top_racket
	    player2_racket = bottom_racket
	else
		bot_racket = top_racket
		player_racket = bottom_racket
	end

    -- создаём мячик
    local ball = display.newCircle(display.contentCenterX, display.contentCenterY, 15)
    ball:setFillColor(1, 0, 0)
    physics.addBody(ball, "dynamic", {bounce = 1})

    -- создаём переменные для значений очков каждого игрока и выводим их
	local top_score = 0
	local top_score_text = display.newText {
		text = top_score,
		x = 0,
		y = 0,
		font = "ObelixPro",
		fontSize = 35
	}
	top_score_text:setFillColor(0)
	top_score_text.anchorX = 0
	local bottom_score = 0
	local bottom_score_text = display.newText {
		text = bottom_score,
		x = maxWidth,
		y = maxHeight - 85,
		font = "ObelixPro",
		fontSize = 35
	}
	bottom_score_text:setFillColor(0)
	bottom_score_text.anchorX = 1

	if game_mode == "multiplayer" then
	    player1_score = top_score
	    player1_score_text = top_score_text
	    player2_score = bottom_score
	    player2_score_text = bottom_score_text
	else
		bot_score = top_score
		bot_score_text = top_score_text
		player_score = bottom_score
		player_score_text = bottom_score_text
	end

    local function launch_ball()
        physics.start()
        if ball.x == display.contentCenterX and ball.y == display.contentCenterY then
            local direction = math.random(4)
            if direction == 1 then
                ball:setLinearVelocity(-maxWidth/2, -maxWidth/2)
            elseif direction == 2 then
                ball:setLinearVelocity(maxWidth/2, -maxWidth/2)
            elseif direction == 3 then
                ball:setLinearVelocity(-maxWidth/2, maxWidth/2)
            elseif direction == 4 then
                ball:setLinearVelocity(maxWidth/2, maxWidth/2)
            end
        end
    end
    ball:addEventListener("tap", launch_ball)

	local function move_racket(event)
	    local racket = event.target
	    local phase = event.phase

	    if phase == "began" then
			display.getCurrentStage():setFocus(racket, event.id)
	        lastX = event.x - racket.x
	    elseif phase == "moved" then
	        racket.x = event.x - lastX
		elseif phase == "ended" or phase == "cancelled" then
	        display.getCurrentStage():setFocus(racket, nil)
	    end
	    return true
	end
	bottom_racket:addEventListener("touch", move_racket)
	if game_mode == "multiplayer" then
    	top_racket:addEventListener("touch", move_racket)
	end

    local function game_loop()
		if game_mode == "singleplayer" then
			bot_racket.x = ball.x
		end

        if ball.y < 0 or ball.y > maxHeight then
            -- обновляем значения очков
			if ball.y < 0 then
				bottom_score = bottom_score + 1
				bottom_score_text.text = bottom_score
			else
				top_score = top_score + 1
				top_score_text.text = top_score
			end

            -- восстанавливем позиции ракеток
			top_racket.x = display.contentCenterX
			top_racket.y = 0
			bottom_racket.x = display.contentCenterX
			bottom_racket.y = maxHeight - 85

            -- восстанавливаем позицию мячика
            ball.x = display.contentCenterX
            ball.y = display.contentCenterY

            -- останавливаем физику, чтобы мячик не двигался
            -- при нажатии на мячик, физика снова включится
            physics.pause()
        end
    end
    local game_loop_timer = timer.performWithDelay(20, game_loop, 0)
end

scene:addEventListener("create", scene)

return scene
