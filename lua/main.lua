-- #####################################################################################################
-- 
-- ┌──────────────────┐                                    ┌──┐
-- └───────┐  ┌───────┘                                    │  │
--         │  │                                       ─────┘  └──┐                 ┌──┐
--         │  │                                     /──────┐  ┌──┘                 └──┘
--         │  │    ┌──────────┐                            │  │
--         │  │    │  ┌───────┘    ┌────────────────       │  │    |\    ─────┐    ┌──┐      ────────
--         │  │    │  │            │  ┌────┐  ┌────┐ \     │  │    │ \ /   ───┘    │  │    /   ───────\
--         │  │    │  └───┐        │  │    │  │    │  │    │  │    │     /         │  │     \  \
--         │  │    │  ┌───┘        │  │    │  │    │  │    │  │    │   /           │  │        \  \
--         │  │    │  │            │  │    │  │    │  │    │  │    │  │            │  │           \  \
--         │  │    │  └───────┐    │  │    │  │    │  │    │  │    │  │            │  │     ─────     /
--         │  │    └──────────┘    └──┘    └──┘    └──┘    └──┘    └──┘            └──┘     \────────/
--         │ /
--         │/
-- 
-- #####################################################################################################
--                                                        Port Temtris.py (Python) => Temtris (LÖVE Lua)
--                                          https://github.com/Kimel-PK/Temtris.py
--                                                                                              Kimel_PK
-- #####################################################################################################

local tetrominos = require("tetrominos")
local bit = require("bit")

local toDraw = {}

Sprite = {}
Sprite.__index = Sprite

function Sprite:new(image, x, y, quadX, quadY, quadW, quadH)
    local imgW, imgH = image:getDimensions()

    quadX = quadX and quadX * 32 or 0
    quadY = quadY and quadY * 32 or 0
    quadW = quadW and quadW * 32 or imgW
    quadH = quadH and quadH * 32 or imgH

    return setmetatable({
        image = image,
        quad = love.graphics.newQuad(quadX, quadY, quadW, quadH, imgW, imgH),
        x = x,
        y = y
    }, Sprite)
end

function Sprite:draw()
    love.graphics.draw(self.image, self.quad, self.x * 32, self.y * 32)
end

pressedKeys = {false, false, false, false, false, false, false, false}
pressedKeysLastFrame = {false, false, false, false, false, false, false, false}

gameState = "menu"
linesToBreak = {}
animFrame = 0
debugText = "" -- DEBUG

-- ---------------------
--        Main
-- ---------------------

function love.load()
    math.randomseed(os.time())
    resetVariables()
    loadAssets()
    menu_start()
end

function love.update(dt)
    processInput()
    
    if gameState == "menu" then
        menu_update()
    elseif gameState == "game" then
        game_update()
    elseif gameState == "game_multi" then
        game_multi_update()
    end
end

function love.draw()
    for _, sprite in ipairs(toDraw) do
        sprite:draw()
    end
    toDraw = {}
    
    local text = ""
    text = text.."Curent tetromino: "..currentTetromino.."\n"
    text = text.."Next tetromino: "..nextTetromino.."\n"
    text = text.."Tetromino rotation: "..currentTetrominoRotation.."\n"
    text = text.."Tetromino position: ("..currentTetrominoPosition[1]..","..currentTetrominoPosition[2]..")\n"
    text = text.."Anim frame: "..animFrame.."\n"
    if board ~= nil and currentTetromino > -1 then
        local debugBoard = deepCopy(board)
        for y = 1, 4 do
            for x = 1, 4 do
                if x + currentTetrominoPosition[1] >= 1 and x + currentTetrominoPosition[1] <= 10 and y + currentTetrominoPosition[2] >= 1 and y + currentTetrominoPosition[2] <= 20 then
                    debugBoard[y + currentTetrominoPosition[2]][x + currentTetrominoPosition[1]] = tetrominos[currentTetromino + 1][currentTetrominoRotation + 1][y][x]
                end
            end
        end
        text = text.."1 | "
        for y = 1, #debugBoard do
            for x = 1, #debugBoard[y] do
                text = text..debugBoard[y][x]..", "
            end
            text = text.."\n"..(y + 1).." | "
        end
    end
    text = text.."\n"..debugText
    love.graphics.print(text, 0, 0)
end

function resetVariables()
    pause = False
    level = 0
    linesCount = {0, 0}
    cheemsLinesCount = {0, 0}
    dogeLinesCount = {0, 0}
    buffDogeLinesCount = {0, 0}
    temtrisLinesCount = {0, 0}
    points = {0, 0}
    gameTime = 0
    twoPlayerMode = False
    currentPlayer = 0
    inputTimer = 10
    inputRotateTimer = 10
    fallSpeed = 60
    fallTimer = 60
end

function loadAssets()
    -- sfx
    hitSFX = love.audio.newSource("assets/sfx/hit.ogg", "static")
    
    cheemsSFX = love.audio.newSource("assets/sfx/cheems.ogg", "static")
    dogeSFX = love.audio.newSource("assets/sfx/doge.ogg", "static")
    buffdogeSFX = love.audio.newSource("assets/sfx/buffdoge.ogg", "static")
    temtrisSFX = love.audio.newSource("assets/sfx/temtris.ogg", "static")
    
    introSFX = love.audio.newSource("assets/sfx/intro.ogg", "static")
    temtrisTheme = love.audio.newSource("assets/sfx/temtris_theme.ogg", "stream")
    music = {
        love.audio.newSource("assets/sfx/never_gonna_give_you_up_nes_apu_cover.ogg", "stream"),
        love.audio.newSource("assets/sfx/together_forever_nes_apu_cover.ogg", "stream"),
        love.audio.newSource("assets/sfx/song_for_denise_nes_apu_cover.ogg", "stream"),
        love.audio.newSource("assets/sfx/szanty_bitwa_nes_apu_cover.ogg", "stream")
    }
    
    -- gfx
    menuBg = love.graphics.newImage("assets/gfx/menu_bg.png")
    gameBg = love.graphics.newImage("assets/gfx/game_bg.png")
    gameMultiBg = love.graphics.newImage("assets/gfx/game_multi_bg.png")
    gameOverBg = love.graphics.newImage("assets/gfx/game_over_1.png")
    gameOver2Bg = love.graphics.newImage("assets/gfx/game_over_2.png")
    gameOverMultiBg = love.graphics.newImage("assets/gfx/game_over_multi.png")
    
    introSprite = love.graphics.newImage("assets/gfx/intro_sprite.png")
    arrowSprite = love.graphics.newImage("assets/gfx/arrow.png")
    tetrominosSpritesheet = love.graphics.newImage("assets/gfx/tetrominos_spritesheet.png")
    p1tetrominosSpritesheet = love.graphics.newImage("assets/gfx/tetrominos_p1_spritesheet.png")
    p2tetrominosSpritesheet = love.graphics.newImage("assets/gfx/tetrominos_p2_spritesheet.png")
    fragmentsSpritesheet = love.graphics.newImage("assets/gfx/fragments_spritesheet.png")
    breakLineAnimSpritesheet = love.graphics.newImage("assets/gfx/line_break_anim_spritesheet.png")
    digitsSpritesheet = love.graphics.newImage("assets/gfx/digits_spritesheet.png")
    
    pauseSprite = love.graphics.newImage("assets/gfx/pause.png")
    skullSprite = love.graphics.newImage("assets/gfx/skull.png")
    crownSprite = love.graphics.newImage("assets/gfx/crown.png")
end

-- ---------------------
--        Input
-- ---------------------

function processInput()
    pressedKeysLastFrame = pressedKeys
    pressedKeys = {false, false, false, false, false, false, false, false}
    
    if love.keyboard.isDown("k") then
        pressedKeys[0] = true
    end
    if love.keyboard.isDown("l") then
        pressedKeys[1] = true
    end
    if love.keyboard.isDown("up") then
        pressedKeys[2] = true
    end
    if love.keyboard.isDown("down") then
        pressedKeys[3] = true
    end
    if love.keyboard.isDown("left") then
        pressedKeys[4] = true
    end
    if love.keyboard.isDown("right") then
        pressedKeys[5] = true
    end
    if love.keyboard.isDown("return") then
        pressedKeys[6] = true
    end
    if love.keyboard.isDown("rshift") then
        pressedKeys[7] = true
    end
end

-- ---------------------
--        Intro
-- ---------------------

-- ---------------------
--         Menu
-- ---------------------

function menu_start()
    temtrisTheme:setLooping(true)
    temtrisTheme:play()
end

function menu_update()
    if pressedKeys[2] and not pressedKeysLastFrame[2] then
        twoPlayerMode = not twoPlayerMode
    elseif pressedKeys[3] and not pressedKeysLastFrame[3] then
        twoPlayerMode = not twoPlayerMode
    elseif love.keyboard.isDown("return") then
        menu_end()
        gameState = "game"
        game_start()
    end
    
    table.insert(toDraw, Sprite:new(menuBg, 0, 0))
    if twoPlayerMode then
        table.insert(toDraw, Sprite:new(arrowSprite, 4, 21))
    else
        table.insert(toDraw, Sprite:new(arrowSprite, 4, 20))
    end
end

function menu_end()
    temtrisTheme:stop()
end

-- ---------------------
--         Game
-- ---------------------

board = {
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
}
currentTetromino = -1
nextTetromino = -1
currentTetrominoPosition = {3, 0}
currentTetrominoRotation = 0

function game_start()
    nextTetromino = math.random(0, 6)
    fallTimer = fallSpeed
end

function game_update()
    -- play music if is not playing
    if not music[1]:isPlaying() and not music[2]:isPlaying() and not music[3]:isPlaying() and not music[4]:isPlaying() then
        music[math.random(1, 4)]:play()
    end
    
    -- animate line break
    if #linesToBreak > 0 then
        
        if animFrame == 0 then
            if #linesToBreak == 1 then
                cheemsSFX:play()
            elseif #linesToBreak == 2 then
                dogeSFX:play()
            elseif #linesToBreak == 3 then
                buffdogeSFX:play()
            elseif #linesToBreak == 4 then
                temtrisSFX:play()
            end
        elseif animFrame > 31 then
            animFrame = 0
            breakLines()
            game_draw()
            return
        end
        
        animFrame = animFrame + 1
        game_draw()
        
        for i, y in ipairs(linesToBreak) do
            table.insert(toDraw, Sprite:new(breakLineAnimSpritesheet, 10, 4 + y, (#linesToBreak - 1) * 10, animFrame, 10, 1))
        end
        
        -- DEBUG
        debugText = ""
        for i, y in pairs(linesToBreak) do
            local realY = y - i + 1
            
            if realY - 1 >= 1 then
                debugText = debugText.."remove bottoms from "..(realY - 1)..", \n"
            end
            debugText = debugText.."remove row "..(realY)..", \n"
            if realY + 1 <= 20 then
                debugText = debugText.."remove tops from "..(realY + 1)..", \n"
            end
        end
        return
    end
    
    -- spawn new tetromino
    spawnTetromino()
    
    fallTimer = fallTimer - 1
    if fallTimer == 0 then
        fallTimer = fallSpeed
        tetrominoFall()
    end

    -- input logic
    
    if inputTimer > 0 then
        inputTimer = inputTimer - 1
    end
    
    if inputTimer == 0 and currentTetromino > -1 then
		
        -- RIGHT
        if pressedKeys[5] then
            moveTetrominoRight()
            if pressedKeysLastFrame[5] then
                inputTimer = 3
            else
                inputTimer = 10
            end
        -- LEFT
        elseif pressedKeys[4] then
            moveTetrominoLeft()
            if pressedKeysLastFrame[4] then
                inputTimer = 3
            else
                inputTimer = 10
            end
        -- DOWN
        elseif pressedKeys[3] then
            fallTimer = fallSpeed
            if pressedKeysLastFrame[3] then
                inputTimer = 3
            else
                inputTimer = 10
            end
            tetrominoFall()
        end
    end
        
    -- rotation
    if inputRotateTimer > 0 then
        inputRotateTimer = inputRotateTimer - 1
    end
    
    if inputRotateTimer == 0 and currentTetromino > -1 then
        -- B
        if pressedKeys[0] then
            rotateTetrominoLeft()
            inputRotateTimer = 10
        -- A
        elseif pressedKeys[1] then
            rotateTetrominoRight()
            inputRotateTimer = 10
        end
    end
    
    if pressedKeys[6] and not pressedKeysLastFrame[6] then
        -- TODO toggle pause
    end
    if pressedKeys[7] and not pressedKeysLastFrame[7] then
        music[1]:stop()
        music[2]:stop()
        music[3]:stop()
        music[4]:stop()
    end

    game_draw()
end

function game_end()
    music[1]:stop()
    music[2]:stop()
    music[3]:stop()
    music[4]:stop()
end

function game_draw()
    -- draw bg
    table.insert(toDraw, Sprite:new(gameBg, 0, 0))
    
    -- draw counters
    drawP1LinesCounter()
    drawP1PointsCounter()
    
    -- draw board
    drawNextTetromino()
    drawFallingTetromino()
    drawBoard()
end

function drawP1LinesCounter()
    local thousands = math.floor(linesCount[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 4, 9, thousands, 0, 1, 1))
    local hundreds = math.floor(linesCount[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 5, 9, hundreds, 0, 1, 1))
    local tens = math.floor(linesCount[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 6, 9, tens, 0, 1, 1))
    local digits = linesCount[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 7, 9, digits, 0, 1, 1))
end

function drawP1PointsCounter()
    local thousands = math.floor(points[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 4, 12, thousands, 0, 1, 1))
    local hundreds = math.floor(points[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 5, 12, hundreds, 0, 1, 1))
    local tens = math.floor(points[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 6, 12, tens, 0, 1, 1))
    local digits = points[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 7, 12, digits, 0, 1, 1))
end

function spawnTetromino()
    if currentTetromino > -1 then
        return
    end
    currentTetromino = nextTetromino
    currentTetrominoPosition = {3, 0}
    currentTetrominoRotation = 0
    
    nextTetromino = math.random(0, 6)
    
    if checkCollision(0, 0, 0) then
        -- TODO game over
        game_end()
        gameState = "menu"
        menu_start()
    end
end

function drawNextTetromino()
    if nextTetromino > -1 then
        table.insert(toDraw, Sprite:new(tetrominosSpritesheet, 4, 4, 0, nextTetromino * 4, 4, 4))
    end
end

function drawFallingTetromino()
    if currentTetromino > -1 then
        table.insert(toDraw, Sprite:new(tetrominosSpritesheet, currentTetrominoPosition[1] + 10, currentTetrominoPosition[2] + 5, currentTetrominoRotation * 4, currentTetromino * 4, 4, 4))
    end
end

function drawBoard()
    for y = 1, #board do
        for x = 1, #board[y] do
            local value = board[y][x]
            if value >= 0 then
                table.insert(toDraw, Sprite:new(fragmentsSpritesheet, x + 9, y + 4, value, level % 16, 1, 1))
            end
        end
    end
end

function tetrominoFall()
    if checkCollision(0, 1, 0) then
        placeTetromino()
        hitSFX:play()
    else
        currentTetrominoPosition[2] = currentTetrominoPosition[2] + 1
    end
end

function checkCollision(offsetX, offsetY, offsetR)
    for y = 1, 4 do
        for x = 1, 4 do
            local tetrominoFrag = tetrominos[currentTetromino + 1][((currentTetrominoRotation + offsetR) % 4) + 1][y][x]
            if tetrominoFrag > -1 then
                -- oob
                if currentTetrominoPosition[1] + x + offsetX < 1 or currentTetrominoPosition[1] + x + offsetX > 10 then
                    return true
                end
                if currentTetrominoPosition[2] + y + offsetY < 1 or currentTetrominoPosition[2] + y + offsetY > 20 then
                    return true
                end
                -- collision with other fragment
                if board[currentTetrominoPosition[2] + y + offsetY][currentTetrominoPosition[1] + x + offsetX] > -1 then
                    return true
                end
            end
        end
    end
    return false
end

function moveTetrominoLeft()
    if not checkCollision(-1, 0, 0) then
        currentTetrominoPosition[1] = currentTetrominoPosition[1] - 1
    end
end

function moveTetrominoRight()
    if not checkCollision(1, 0, 0) then
        currentTetrominoPosition[1] = currentTetrominoPosition[1] + 1
    end
end

function rotateTetrominoRight()
    if not checkCollision(0, 0, 1) then
        currentTetrominoRotation = (currentTetrominoRotation + 1) % 4
    elseif not checkCollision(-1, 0, 1) then
        currentTetrominoPosition[1] = currentTetrominoPosition[1] - 1
        currentTetrominoRotation = (currentTetrominoRotation + 1) % 4
    end
end

function rotateTetrominoLeft()
    if not checkCollision(0, 0, -1) then
        currentTetrominoRotation = (currentTetrominoRotation - 1) % 4
    elseif not checkCollision(1, 0, -1) then
        currentTetrominoPosition[1] = currentTetrominoPosition[1] + 1
        currentTetrominoRotation = (currentTetrominoRotation - 1) % 4
    end
end

function placeTetromino()
    for y = 1, 4 do
        for x = 1, 4 do
            if tetrominos[currentTetromino + 1][currentTetrominoRotation + 1][y][x] > -1 then
                board[y + currentTetrominoPosition[2]][x + currentTetrominoPosition[1]] = tetrominos[currentTetromino + 1][currentTetrominoRotation + 1][y][x]
            end
        end
    end
    
    currentTetromino = -1
    
    -- check if any line to break
    for y = 1, 20 do
        local fragmentsCount = 0
        for x = 1, 10 do
            if board[y][x] > -1 then
                fragmentsCount = fragmentsCount + 1
            end
        end
        if fragmentsCount == 10 then
            table.insert(linesToBreak, y)
        end
    end
end

function breakLines()
    -- remove and update fragments
    for i, y in pairs(linesToBreak) do
        local realY = y - i + 1
        
        if realY - 1 >= 1 then
            for x = 1, 10 do
                if board[realY - 1][x] > -1 then
                    board[realY - 1][x] = bit.band(board[realY - 1][x], bit.bnot(2))
                end
            end
        end
        if realY + 1 <= 20 then
            for x = 1, 10 do
                if board[realY + 1][x] > -1 then
                    board[realY + 1][x] = bit.band(board[realY - 1][x], bit.bnot(4))
                end
            end
        end
        table.remove(board, realY)
        table.insert(board, 1, {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,})
    end
    
    -- count lines
    linesCount[1] = linesCount[1] + #linesToBreak
    if #linesToBreak == 1 then
        cheemsLinesCount[1] = cheemsLinesCount[1] + 1
    elseif #linesToBreak == 2 then
        dogeLinesCount[1] = dogeLinesCount[1] + 1
    elseif #linesToBreak == 3 then
        buffDogeLinesCount[1] = buffDogeLinesCount[1] + 1
    elseif #linesToBreak == 4 then
        temtrisLinesCount[1] = temtrisLinesCount[1] + 1
    end
    level = math.floor(linesCount[1] / 30)
    
    linesToBreak = {}
end

function deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end