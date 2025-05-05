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

local utility = require("utility")
local tetrominos = require("tetrominos")
local saveState = require("save_state")
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

gameState = "intro"
linesToBreak = {}
animFrame = 0
debugText = "" -- DEBUG
saveStateInfoText = ""
saveStateInfoTimer = -1

-- ---------------------
--        Main
-- ---------------------

function love.load()
    math.randomseed(os.time())
    resetVariables()
    loadAssets()
end

function love.update(dt)
    processInput()
    
    if gameState == "intro" then
        introUpdate()
    elseif gameState == "menu" then
        menuUpdate()
    elseif gameState == "game" then
        gameUpdate(dt)
    elseif gameState == "game_multi" then
        gameMultiUpdate()
    elseif gameState == "game_over" then
        gameOverUpdate()
    end
end

function love.draw()
    for _, sprite in ipairs(toDraw) do
        sprite:draw()
    end
    toDraw = {}
    
    drawTextOverlay()
    -- DEBUG
    -- debugDraw()
end

function love.keypressed(key)
    if key == "1" then
        if gameState ~= "game" then
            saveStateInfoText = "State can only be saved ingame!"
            saveStateInfoTimer = 120
            return
        end
        saveState.save()
        saveStateInfoText = "Game state saved!"
        saveStateInfoTimer = 120
    elseif key == "2" then
        if gameState ~= "game" then
            saveStateInfoText = "State can only be loaded ingame!"
            saveStateInfoTimer = 120
            return
        end
        if not saveState.isSthSaved then
            saveStateInfoText = "No state data saved!"
            saveStateInfoTimer = 120
            return
        end
        saveState.load()
        saveStateInfoText = "Game state loaded!"
        saveStateInfoTimer = 120
    end
end

function drawTextOverlay()
    
    local text = ""
    text = text.."Player 1:\n"
    text = text.."Enter - start game / pause\n"
    text = text.."Right shift - play random music\n"
    text = text.."Arrow keys - move\n"
    text = text.."K - rotate left\n"
    text = text.."L - rotate right\n"
    text = text.."\n"
    text = text.."1 - save game state\n"
    text = text.."2 - load game state\n"
    love.graphics.print(text, 10, 10)
    
    if saveStateInfoTimer > -1 then
        local defaultFont = love.graphics.getFont()
        local bigFont = love.graphics.newFont(32)
        love.graphics.setFont(bigFont)
        love.graphics.print(saveStateInfoText, 20, 840)
        saveStateInfoTimer = saveStateInfoTimer - 1
        love.graphics.setFont(defaultFont)
    end
        
end

function debugDraw()
    local text = ""
    text = text.."Curent tetromino: "..currentTetromino.."\n"
    text = text.."Next tetromino: "..nextTetromino.."\n"
    text = text.."Tetromino rotation: "..currentTetrominoRotation.."\n"
    text = text.."Tetromino position: ("..currentTetrominoPosition[1]..","..currentTetrominoPosition[2]..")\n"
    text = text.."Game time: "..gameTime.."\n"
    
    love.graphics.print(text, 800, 10)
    
    if board ~= nil and currentTetromino > -1 then
        local debugBoard = utility.deepCopy(board)
        for y = 1, 4 do
            for x = 1, 4 do
                if x + currentTetrominoPosition[1] >= 1 and x + currentTetrominoPosition[1] <= 10 and y + currentTetrominoPosition[2] >= 1 and y + currentTetrominoPosition[2] <= 20 then
                    if tetrominos[currentTetromino + 1][currentTetrominoRotation + 1][y][x] > -1 then
                        debugBoard[y + currentTetrominoPosition[2]][x + currentTetrominoPosition[1]] = tetrominos[currentTetromino + 1][currentTetrominoRotation + 1][y][x]
                    end
                end
            end
        end
        text = text.."1 | "
        love.graphics.setColor(1, 0, 0)
        for y = 1, #debugBoard do
            love.graphics.print(y, 8 * 32 + 9, 4 * 32 + y * 32 + 9)
            for x = 1, #debugBoard[y] do
                love.graphics.print(debugBoard[y][x], 9 * 32 + x * 32 + 9, 4 * 32 + y * 32 + 9)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
end

function resetVariables()
    board = {{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1},}
    pause = false
    level = 0
    linesCount = {0, 0}
    cheemsLinesCount = {0, 0}
    dogeLinesCount = {0, 0}
    buffDogeLinesCount = {0, 0}
    temtrisLinesCount = {0, 0}
    points = {0, 0}
    gameTime = 0
    twoPlayerMode = false
    currentPlayer = 0
    inputTimer = 10
    inputRotateTimer = 10
    fallSpeed = 60
    fallTimer = 60
    gameOverAnimFrame = 0
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
    gameOverTheme = love.audio.newSource("assets/sfx/game_over.ogg", "static")
    
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

introAnimFrame = 0

function introUpdate()
    
    if pressedKeys[6] and not pressedKeysLastFrame[6] then
        introSFX:stop()
        gameState = "menu"
        menuStart()
    end
    
    if introAnimFrame < 30 then
    elseif introAnimFrame == 30 then
        introSFX:play()
        table.insert(toDraw, Sprite:new(introSprite, 6, 9, 0, 0, 19, 10))
    elseif introAnimFrame < 60 then
        table.insert(toDraw, Sprite:new(introSprite, 6, 9, 0, 0, 19, 10))
    elseif introAnimFrame < 90 then
        table.insert(toDraw, Sprite:new(introSprite, 6, 9, 0, 10, 19, 10))
    elseif introAnimFrame < 120 then
        table.insert(toDraw, Sprite:new(introSprite, 6, 9, 0, 20, 19, 10))
    elseif introAnimFrame < 300 then
        table.insert(toDraw, Sprite:new(introSprite, 6, 9, 0, 30, 19, 10))
    elseif introAnimFrame > 300 then
        gameState = "menu"
        menuStart()
    end
    
    introAnimFrame = introAnimFrame + 1
end

-- ---------------------
--         Menu
-- ---------------------

function menuStart()
    temtrisTheme:setLooping(true)
    temtrisTheme:play()
end

function menuUpdate()
    --[[
    if pressedKeys[2] and not pressedKeysLastFrame[2] then
        twoPlayerMode = not twoPlayerMode
    elseif pressedKeys[3] and not pressedKeysLastFrame[3] then
        twoPlayerMode = not twoPlayerMode
    end
    --]]
    if pressedKeys[6] and not pressedKeysLastFrame[6] then
        menuEnd()
        gameState = "game"
        gameStart()
    end
    
    table.insert(toDraw, Sprite:new(menuBg, 0, 0))
    if twoPlayerMode then
        table.insert(toDraw, Sprite:new(arrowSprite, 4, 21))
    else
        table.insert(toDraw, Sprite:new(arrowSprite, 4, 20))
    end
end

function menuEnd()
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

function gameStart()
    resetVariables()
    nextTetromino = math.random(0, 6)
    fallTimer = fallSpeed
    pause = false
end

function gameUpdate(dt)
    -- play music if is not playing
    if not music[1]:isPlaying() and not music[2]:isPlaying() and not music[3]:isPlaying() and not music[4]:isPlaying() then
        music[math.random(1, 4)]:play()
    end
    
    if pressedKeys[6] and not pressedKeysLastFrame[6] then
        pause = not pause
    end
    
    if pause then
        game_draw()
        return
    end
    
    -- animate line break
    if #linesToBreak > 0 then
        
        if animFrame == 29 then
            if #linesToBreak == 1 then
                cheemsSFX:play()
            elseif #linesToBreak == 2 then
                dogeSFX:play()
            elseif #linesToBreak == 3 then
                buffdogeSFX:play()
            elseif #linesToBreak == 4 then
                temtrisSFX:play()
            end
        elseif animFrame > 30 then
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
    
    if pressedKeys[7] and not pressedKeysLastFrame[7] then
        music[1]:stop()
        music[2]:stop()
        music[3]:stop()
        music[4]:stop()
    end
    
    gameTime = gameTime + dt

    game_draw()
end

function game_end()
    pause = true
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
    drawBoard()
    drawFallingTetromino()
    
    -- draw pause text
    if pause and gameState == "game" then
        table.insert(toDraw, Sprite:new(pauseSprite, 12, 2))
    end
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
        game_end()
        gameState = "game_over"
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
            table.insert(linesToBreak, 1, y)
        end
    end
end

function breakLines()
    -- remove and update fragments
    for i, y in pairs(linesToBreak) do
        if y - 1 >= 1 then
            for x = 1, 10 do
                if board[y - 1][x] > -1 then
                    board[y - 1][x] = bit.band(board[y - 1][x], bit.bnot(2))
                end
            end
        end
        if y + 1 <= 20 and y + 1 <= #board then
            for x = 1, 10 do
                if board[y + 1][x] > -1 then
                    board[y + 1][x] = bit.band(board[y + 1][x], bit.bnot(8))
                end
            end
        end
        table.remove(board, y)
    end
    
    for i = 1, #linesToBreak do
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
    
    -- count points
    if #linesToBreak == 1 then
        points[1] = points[1] + 1
    elseif #linesToBreak == 2 then
        points[1] = points[1] + 4
    elseif #linesToBreak == 3 then
        points[1] = points[1] + 6
    elseif #linesToBreak == 4 then
        points[1] = points[1] + 8
    end
    
    linesToBreak = {}
end

-- ---------------------
--      Game over
-- ---------------------

gameOverAnimFrame = 0

function gameOverUpdate()
    
    gameOverAnimFrame = gameOverAnimFrame + 1
    
    if pressedKeys[6] and not pressedKeysLastFrame[6] then
        gameOverTheme:stop()
        gameState = "menu"
        menuStart()
    end
    
    if gameOverAnimFrame < 60 then
        game_draw()
        return
    elseif gameOverAnimFrame == 60 then
        gameOverTheme:play()
        table.insert(toDraw, Sprite:new(gameOverBg, 0, 0))
        return
    elseif gameOverAnimFrame < 150 then
        table.insert(toDraw, Sprite:new(gameOverBg, 0, 0))
        return
    end
    
    table.insert(toDraw, Sprite:new(gameOver2Bg, 0, 0))
    
    -- draw p1 points
    local thousands = math.floor(points[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 11, 13, thousands, 0, 1, 1))
    local hundreds = math.floor(points[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 12, 13, hundreds, 0, 1, 1))
    local tens = math.floor(points[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 13, 13, tens, 0, 1, 1))
    local digits = points[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 14, 13, digits, 0, 1, 1))
    
    -- draw p1 lines
    local thousands = math.floor(linesCount[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 11, 15, thousands, 0, 1, 1))
    local hundreds = math.floor(linesCount[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 12, 15, hundreds, 0, 1, 1))
    local tens = math.floor(linesCount[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 13, 15, tens, 0, 1, 1))
    local digits = linesCount[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 14, 15, digits, 0, 1, 1))
    
    -- draw p1 cheems lines
    local thousands = math.floor(cheemsLinesCount[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 11, 17, thousands, 0, 1, 1))
    local hundreds = math.floor(cheemsLinesCount[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 12, 17, hundreds, 0, 1, 1))
    local tens = math.floor(cheemsLinesCount[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 13, 17, tens, 0, 1, 1))
    local digits = cheemsLinesCount[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 14, 17, digits, 0, 1, 1))
    
    -- draw p1 doge lines
    local thousands = math.floor(dogeLinesCount[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 11, 19, thousands, 0, 1, 1))
    local hundreds = math.floor(dogeLinesCount[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 12, 19, hundreds, 0, 1, 1))
    local tens = math.floor(dogeLinesCount[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 13, 19, tens, 0, 1, 1))
    local digits = dogeLinesCount[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 14, 19, digits, 0, 1, 1))
    
    -- draw p1 buffdoge lines
    local thousands = math.floor(buffDogeLinesCount[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 11, 21, thousands, 0, 1, 1))
    local hundreds = math.floor(buffDogeLinesCount[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 12, 21, hundreds, 0, 1, 1))
    local tens = math.floor(buffDogeLinesCount[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 13, 21, tens, 0, 1, 1))
    local digits = buffDogeLinesCount[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 14, 21, digits, 0, 1, 1))
    
    -- draw p1 temtris lines
    local thousands = math.floor(temtrisLinesCount[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 11, 23, thousands, 0, 1, 1))
    local hundreds = math.floor(temtrisLinesCount[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 12, 23, hundreds, 0, 1, 1))
    local tens = math.floor(temtrisLinesCount[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 13, 23, tens, 0, 1, 1))
    local digits = temtrisLinesCount[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 14, 23, digits, 0, 1, 1))
    
    -- draw game time
    gameTime = math.floor(gameTime)
    local minutes = gameTime / 60
    local seconds = gameTime % 60
    
    -- minutes
    local minutesHundreds = math.floor(minutes / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 11, 25, minutesHundreds, 0, 1, 1))
    local minutesTens = math.floor(minutes / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 12, 25, minutesTens, 0, 1, 1))
    local minutesDigits = math.floor(minutes) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 13, 25, minutesDigits, 0, 1, 1))
    -- seconds
    local secondsTens = math.floor(seconds / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 15, 25, secondsTens, 0, 1, 1))
    local secondsDigits = math.floor(seconds) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 16, 25, secondsDigits, 0, 1, 1))
end