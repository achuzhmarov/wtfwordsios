import Foundation

extension GameController {
    func loadBoardFromCache(_ boardCacheForWord: BoardCache) {
        tiles = boardCacheForWord.tiles
        fixedTiles = boardCacheForWord.fixedTiles
        targets = boardCacheForWord.targets

        if (boardCacheForWord.isLettersHintDisabled) {
            disableLettersHintButton()
        }

        //create targets
        for position in 0 ..< targets.count {
            addTargetToView(targets[position], position: position)
        }

        //create fixed tiles
        for fixedTile in fixedTiles {
            putFixedTileToBoard(fixedTile)
        }

        //create tiles
        for tileIndex in 0 ..< tiles.count {
            let tile: TileView = tiles[tileIndex]
            tile.updateBackground()
            addTileToView(tile, tileIndex: tileIndex)

            if (tile.isPlaced) {
                tile.center = tile.placedOnTarget!.center
            }
        }
    }

    func generateNewBoard() {
        targets = []

        //create targets
        for position in 0 ..< wordText.characters.count {
            let target = TargetView(letter: Character(wordText[position]), sideLength: targetSide)
            addTargetToView(target, position: position)
            targets.append(target)
        }

        if (cipherType == .shuffle) {
            generateShuffleFixedTiles()
        } else {
            generateGeneralFixedTiles()
        }

        generateTiles()

        if (cipherType == .shuffle) {
            highlightWordLettersForShuffle()
        }

        saveBoardToCache()
    }

    func saveBoardToCache() {
        var isLettersHintUsed: Bool

        if let isEnabled = hudView.lettersButton?.isEnabled {
            isLettersHintUsed = !isEnabled
        } else {
            isLettersHintUsed = false
        }

        boardCache[word] = BoardCache(
                tiles: tiles,
                fixedTiles: fixedTiles,
                targets: targets,
                isLettersHintUsed: isLettersHintUsed
                )
    }

    private func generateTiles() {
        tiles = []
        let letters = generateLetters()

        for tileIndex in 0 ..< letters.characters.count {
            let tile = TileView(letter: Character(letters[tileIndex]), sideLength: tileSide)
            tiles.append(tile)
            addTileToView(tile, tileIndex: tileIndex)
        }
    }

    private func addTileToView(_ tile: TileView, tileIndex: Int) {
        var targetOffset: CGFloat

        if (wordLength <= MaxTargetsPerRow) {
            targetOffset = (targetSide + VerticalPadding) + VerticalPadding * 2
        } else {
            targetOffset = (targetSide + VerticalPadding) * 2 + VerticalPadding * 2
        }

        let xLetterOffset = (screenWidth - CGFloat(MaxLettersPerRow) * (tileSide + TileMargin)) / 2.0 + tileSide / 2.0

        let rowIndex = CGFloat(tileIndex / MaxLettersPerRow)
        let columnIndex = CGFloat(tileIndex % MaxLettersPerRow)

        tile.center = CGPoint(x: xLetterOffset + columnIndex * (tileSide + TileMargin),
                y: targetOffset + (tileSide / 2) + (tileSide + VerticalPadding) * rowIndex)

        tile.originalCenter = tile.center

        gameView.addSubview(tile)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tileTapped(_:)))
        tile.addGestureRecognizer(tap)
    }

    private func generateShuffleFixedTiles() {
        fixedTiles = []

        //create first letter for easy difficulty
        if (cipherDifficulty == .easy) {
            generateFixedTile(position: 0)
        }
    }

    private func generateFixedTile(position: Int) {
        let fixedTile = FixedTileView(letter: Character(word.text[position]), sideLength: tileSide, position: position)
        fixedTiles.append(fixedTile)
        putFixedTileToBoard(fixedTile)
    }

    private func putFixedTileToBoard(_ fixedTile: FixedTileView) {
        fixedTile.center = targets[fixedTile.position].center
        gameView.addSubview(fixedTile)
        fixTileOnTarget(fixedTile, targets[fixedTile.position])
        fixedTile.updateBackground()
    }

    private func generateGeneralFixedTiles() {
        fixedTiles = []

        for position in 0 ..< word.text.characters.count {
            if (word.fullCipheredText[position] == ".") {
                continue
            }

            generateFixedTile(position: position)
        }
    }

    private func generateLetters() -> String {
        var result = getHidedLetters()
        let needLetters = LettersOnBoard - result.characters.count

        for _ in 0 ..< needLetters {
            result += TextLanguage.getRandomLetter()
        }

        result = result.shuffle

        return result
    }

    private func getHidedLetters() -> String {
        if (cipherType == .shuffle) {
            let wordLength = word.getCharCount() - 1

            if (cipherDifficulty == .easy) {
                return word.text[1...wordLength]
            } else {
                return word.text
            }
        } else {
            return word.hidedLetters
        }
    }

    private func highlightWordLettersForShuffle() {
        if cipherDifficulty == .hard {
            for position in 0 ..< targets.count {
                if (word.fullCipheredText[position] == ".") {
                    continue
                }

                if !targets[position].isFixed {
                    showLetterForTarget(targets[position])
                }
            }
        } else {
            showLetters()
        }
    }

    private func addTargetToView(_ target: TargetView, position: Int) {
        if (wordLength <= MaxTargetsPerRow) {
            let xTargetOffset = (screenWidth - CGFloat(wordLength) * (targetSide + TargetMargin)) / 2.0 + targetSide / 2.0
            target.center = CGPoint(x: xTargetOffset + CGFloat(position) * (targetSide + TargetMargin), y: targetSide / 2 + VerticalPadding)
        } else {
            let lettersInFirstRow = wordLength / 2 + (wordLength % 2)
            let lettersInSecondRow = wordLength / 2

            let xTargetIndexOffset = CGFloat(position % lettersInFirstRow) * (targetSide + TargetMargin)

            if (position < lettersInFirstRow) {
                let xTargetOffset = (screenWidth - CGFloat(lettersInFirstRow) * (targetSide + TargetMargin)) / 2.0 + targetSide / 2.0
                let yTargetOffset = targetSide / 2 + VerticalPadding
                target.center = CGPoint(x: xTargetOffset + xTargetIndexOffset, y: yTargetOffset)
            } else {
                let xTargetOffset = (screenWidth - CGFloat(lettersInSecondRow) * (targetSide + TargetMargin)) / 2.0 + targetSide / 2.0
                let yTargetOffset = targetSide / 2 + VerticalPadding + (targetSide + VerticalPadding)
                target.center = CGPoint(x: xTargetOffset + xTargetIndexOffset, y: yTargetOffset)
            }
        }

        gameView.addSubview(target)
    }

    func clearBoard() {
        isFinished = false
        fixedTiles.removeAll(keepingCapacity: false)
        tiles.removeAll(keepingCapacity: false)
        targets.removeAll(keepingCapacity: false)

        for view in gameView.subviews {
            view.removeFromSuperview()
        }

        enableLettersHintButton()
    }
}
