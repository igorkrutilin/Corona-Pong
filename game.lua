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
	if game_mode == "multiplayer" then
	    player1_racket = display.newRoundedRect(display.contentCenterX, 0, 60, 20, 15)
	    player1_racket:setFillColor(0)
	    physics.addBody(player1_racket, "static")
	    player2_racket = display.newRoundedRect(display.contentCenterX, maxHeight - 85, 60, 20, 15)
	    player2_racket:setFillColor(0)
	    physics.addBody(player2_racket, "static")
	else
		bot_racket = display.newRoundedRect(display.contentCenterX, 0, 60, 20, 15)
		bot_racket:setFillColor(0)
		physics.addBody(bot_racket, "static")
		player_racket = display.newRoundedRect(display.contentCenterX, maxHeight - 85, 60, 20, 15)
		player_racket:setFillColor(0)
		physics.addBody(player_racket, "static")
	end

    -- создаём мячик
    local ball = display.newCircle(display.contentCenterX, display.contentCenterY, 15)
    ball:setFillColor(1, 0, 0)
    physics.addBody(ball, "dynamic", {bounce = 1})

    -- создаём переменные для значений очков каждого игрока и выводим их
	if game_mode == "multiplayer" then
	    player1_score = 0
	    player1_score_text = display.newText {
	        text = player1_score,
	        x = 0,
	        y = 0,
			font = "ObelixPro",
	        fontSize = 35
	    }
	    player1_score_text:setFillColor(0, 0, 0)
	    player1_score_text.anchorX = 0
	    player2_score = 0
	    player2_score_text = display.newText {
	        text = player2_score,
	        x = maxWidth,
	        y = maxHeight - 85,
			font = "ObelixPro",
	        fontSize = 35
	    }
	    player2_score_text:setFillColor(0, 0, 0)
	    player2_score_text.anchorX = 1
	else
		bot_score = 0
		bot_score_text = display.newText {
		    text = bot_score,
		    x = 0,
		    y = 0,
			font = "ObelixPro",
		    fontSize = 35
		}
		bot_score_text:setFillColor(0, 0, 0)
		bot_score_text.anchorX = 0
		local player_score = 0
		local player_score_text = display.newText {
		    text = player_score,
		    x = maxWidth,
		    y = maxHeight - 85,
			font = "ObelixPro",
		    fontSize = 35
		}
		player_score_text:setFillColor(0, 0, 0)
		player_score_text.anchorX = 1
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
	if game_mode == "multiplayer" then
    	player1_racket:addEventListener("touch", move_racket)
    	player2_racket:addEventListener("touch", move_racket)
	else
		player_racket:addEventListener("touch", move_racket)
	end

    local function game_loop()
		if game_mode == "singleplayer" then
			bot_racket.x = ball.x
		end

        if ball.y < 0 or ball.y > maxHeight then
            -- обновляем значения очков
			if game_mode == "multiplayer" then
	            if ball.y < 0 then
	                player2_score = player2_score + 1
	                player2_score_text.text = player2_score
	            else
	                player1_score = player1_score + 1
	                player1_score_text.text = player1_score
	            end
			else
				if ball.y < 0 then
		            player_score = player_score + 1
		            player_score_text.text = player_score
		        else
		            bot_score = bot_score + 1
		            bot_score_text.text = bot_score
		        end
			end

            -- восстанавливем позиции ракеток
			if game_mode == "multiplayer" then
	            player1_racket.x = display.contentCenterX
	            player1_racket.y = 0
	            player2_racket.x = display.contentCenterX
	            player2_racket.y = maxHeight - 85
			else
				bot_racket.x = display.contentCenterX
		        bot_racket.y = 0
		        player_racket.x = display.contentCenterX
		        player_racket.y = maxHeight - 85
			end

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
