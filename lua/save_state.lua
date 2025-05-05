local utility = require("utility")

saveState = {}
saveState.gameData = {}
saveState.isSthSaved = false

function saveState.save()
    saveState.gameData[1] = gameState
    saveState.gameData[2] = pause
    saveState.gameData[3] = level
    saveState.gameData[4] = utility.deepCopy(linesCount)
    saveState.gameData[5] = utility.deepCopy(cheemsLinesCount)
    saveState.gameData[6] = utility.deepCopy(dogeLinesCount)
    saveState.gameData[7] = utility.deepCopy(buffDogeLinesCount)
    saveState.gameData[8] = utility.deepCopy(temtrisLinesCount)
    saveState.gameData[9] = utility.deepCopy(points)
    saveState.gameData[10] = gameTime
    saveState.gameData[11] = twoPlayerMode
    saveState.gameData[12] = currentPlayer
    saveState.gameData[13] = inputTimer
    saveState.gameData[14] = inputRotateTimer
    saveState.gameData[15] = fallSpeed
    saveState.gameData[16] = fallTimer
    saveState.gameData[17] = utility.deepCopy(board)
    saveState.gameData[18] = currentTetromino
    saveState.gameData[19] = nextTetromino
    saveState.gameData[20] = utility.deepCopy(currentTetrominoPosition)
    saveState.gameData[21] = currentTetrominoRotation
    
    saveState.isSthSaved = true
end

function saveState.load()
    gameState = saveState.gameData[1]
    pause = saveState.gameData[2]
    level = saveState.gameData[3]
    linesCount = saveState.gameData[4]
    cheemsLinesCount = saveState.gameData[5]
    dogeLinesCount = saveState.gameData[6]
    buffDogeLinesCount = saveState.gameData[7]
    temtrisLinesCount = saveState.gameData[8]
    points = saveState.gameData[9]
    gameTime = saveState.gameData[10]
    twoPlayerMode = saveState.gameData[11]
    currentPlayer = saveState.gameData[12]
    inputTimer = saveState.gameData[13]
    inputRotateTimer = saveState.gameData[14]
    fallSpeed = saveState.gameData[15]
    fallTimer = saveState.gameData[16]
    board = utility.deepCopy(saveState.gameData[17])
    currentTetromino = saveState.gameData[18]
    nextTetromino = saveState.gameData[19]
    currentTetrominoPosition = utility.deepCopy(saveState.gameData[20])
    currentTetrominoRotation = saveState.gameData[21]
end

return saveState