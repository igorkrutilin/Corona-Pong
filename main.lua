system.activate( "multitouch" )

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
local player1_racket = display.newRoundedRect(display.contentCenterX, 0, 60, 20, 15)
player1_racket:setFillColor(0)
physics.addBody(player1_racket, "static")
local player2_racket = display.newRoundedRect(display.contentCenterX, maxHeight - 85, 60, 20, 15)
player2_racket:setFillColor(0)
physics.addBody(player2_racket, "static")

-- создаём мячик
local ball = display.newCircle(display.contentCenterX, display.contentCenterY, 15)
ball:setFillColor(1, 0, 0)
physics.addBody(ball, "dynamic", {bounce = 1})

-- создаём переменные для значений очков каждого игрока и выводим их
local player1_score = 0
local player1_score_text = display.newText {
    text = player1_score,
    x = 0,
    y = 0,
    fontSize = 50
}
player1_score_text:setFillColor(0, 0, 0)
player1_score_text.anchorX = 0
local player2_score = 0
local player2_score_text = display.newText {
    text = player2_score,
    x = maxWidth,
    y = maxHeight - 85,
    fontSize = 50
}
player2_score_text:setFillColor(0, 0, 0)
player2_score_text.anchorX = 1

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
player1_racket:addEventListener("touch", move_racket)
player2_racket:addEventListener("touch", move_racket)

local function game_loop()
    if ball.y < 0 or ball.y > maxHeight then
        -- обновляем значения очков
        if ball.y < 0 then
            player2_score = player2_score + 1
            player2_score_text.text = player2_score
        else
            player1_score = player1_score + 1
            player1_score_text.text = player1_score
        end

        -- восстанавливем позиции ракеток
        player1_racket.x = display.contentCenterX
        player1_racket.y = 0
        player2_racket.x = display.contentCenterX
        player2_racket.y = maxHeight - 85

        -- восстанавливаем позицию мячика
        ball.x = display.contentCenterX
        ball.y = display.contentCenterY

        -- останавливаем физику, чтобы мячик не двигался
        -- при нажатии на мячик, физика снова включится
        physics.pause()
    end
end
local game_loop_timer = timer.performWithDelay(500, game_loop, 0)
