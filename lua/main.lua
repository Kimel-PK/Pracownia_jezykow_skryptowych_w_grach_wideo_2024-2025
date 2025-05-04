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
    if gameState == "menu" then
        menu_update()
    elseif gameState == "game" then
        game_update()
    elseif gameState == "game_multi" then
        game_multi_update()
    end
    
    pressedKeysLastFrame = pressedKeys
    pressedKeys = {false, false, false, false, false, false, false, false}
end

function love.draw()
    for _, sprite in ipairs(toDraw) do
        sprite:draw()
    end
    toDraw = {}
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
    clearLineAnimSpritesheet = love.graphics.newImage("assets/gfx/line_break_anim_spritesheet.png")
    digitsSpritesheet = love.graphics.newImage("assets/gfx/digits_spritesheet.png")
    
    pauseSprite = love.graphics.newImage("assets/gfx/pause.png")
    skullSprite = love.graphics.newImage("assets/gfx/skull.png")
    crownSprite = love.graphics.newImage("assets/gfx/crown.png")
end

-- ---------------------
--        Input
-- ---------------------

function love.keypressed(key)
    if key == "k" then
        pressedKeys[0] = true
    elseif key == "l" then
        pressedKeys[1] = true
    elseif key == "up" then
        pressedKeys[2] = true
    elseif key == "down" then
        pressedKeys[3] = true
    elseif key == "left" then
        pressedKeys[4] = true
    elseif key == "right" then
        pressedKeys[5] = true
    elseif key == "return" then
        pressedKeys[6] = true
    elseif key == "rshift" then
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
    nextTetromino = math.random(0, 7)
end

function game_update()
    -- play music if is not playing
    if not music[1]:isPlaying() and not music[2]:isPlaying() and not music[3]:isPlaying() and not music[4]:isPlaying() then
        music[math.random(1, 4)]:play()
    end
    
    -- spawn new tetromino
    if currentTetromino == -1 then
        getTetromino()
    end
    
    -- input logic
    if pressedKeys[0] and not pressedKeysLastFrame[0] then
        currentTetrominoRotation = (currentTetrominoRotation + 1) % 4
    end
    if pressedKeys[1] and not pressedKeysLastFrame[1] then
        currentTetrominoRotation = (currentTetrominoRotation - 1) % 4
    end
    
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

function game_end()
    
end

function drawP1LinesCounter()
    local thousands = math.floor(linesCount[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 4, 9, thousands, 0, thousands + 1, 1))
    local hundreds = math.floor(linesCount[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 5, 9, hundreds, 0, hundreds + 1, 1))
    local tens = math.floor(linesCount[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 6, 9, tens, 0, tens + 1, 1))
    local digits = linesCount[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 7, 9, digits, 0, digits + 1, 1))
end

function drawP1PointsCounter()
    local thousands = math.floor(points[1] / 1000) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 4, 12, thousands, 0, thousands + 1, 1))
    local hundreds = math.floor(points[1] / 100) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 5, 12, hundreds, 0, hundreds + 1, 1))
    local tens = math.floor(points[1] / 10) % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 6, 12, tens, 0, tens + 1, 1))
    local digits = points[1] % 10
    table.insert(toDraw, Sprite:new(digitsSpritesheet, 7, 12, digits, 0, digits + 1, 1))
end

function getTetromino()
    currentTetromino = nextTetromino
    currentTetrominoPosition = {3, 0}
    currentTetrominoRotation = 0
    
    nextTetromino = math.random(0, 7)
end

function drawNextTetromino()
    table.insert(toDraw, Sprite:new(tetrominosSpritesheet, 3, 4, 0, nextTetromino * 4, 4, 4))
end

function drawFallingTetromino()
    table.insert(toDraw, Sprite:new(tetrominosSpritesheet, currentTetrominoPosition[1] + 10, currentTetrominoPosition[2] + 5, currentTetrominoRotation * 4, currentTetromino * 4, 4, 4))
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