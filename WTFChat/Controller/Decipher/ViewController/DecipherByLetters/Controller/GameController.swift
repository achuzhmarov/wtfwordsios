import Foundation
import UIKit
import Localize_Swift

class BoardCache {
    var tiles = [TileView]()
    var fixedTiles = [FixedTileView]()
    var targets = [TargetView]()
    var isLettersHintDisabled = false

    init(tiles: [TileView], fixedTiles: [FixedTileView], targets: [TargetView], isLettersHintDisabled: Bool) {
        self.tiles = tiles
        self.fixedTiles = fixedTiles
        self.targets = targets
        self.isLettersHintDisabled = isLettersHintDisabled
    }
}

class GameController {
    var gameView: UIView!
    private var word: Word!
    var cipherType: CipherType!
    var cipherDifficulty: CipherDifficulty!

    private var tiles = [TileView]()
    private var fixedTiles = [FixedTileView]()
    fileprivate var targets = [TargetView]()

    private var isFinished = false
    private var tileSide: CGFloat!
    private var targetSide: CGFloat!

    private var boardCache = [Word: BoardCache]()

    var hudView: HUDView! {
        didSet {
            //connect the Hint button
            hudView.hintButton.addTarget(self, action: #selector(GameController.actionHint), for: .touchUpInside)
            hudView.solveButton.addTarget(self, action: #selector(GameController.actionSolve), for: .touchUpInside)
            hudView.lettersButton.addTarget(self, action: #selector(GameController.actionLetters), for: .touchUpInside)
        }
    }

    fileprivate var audioController: AudioController

    var onWordSolved: ((_: Word) -> ())!

    private var wordLength: Int {
        return word.text.characters.count
    }

    private var wordText: String {
        return word.text
    }

    private var screenWidth: CGFloat {
        return gameView.bounds.size.width
    }

    init() {
        self.audioController = AudioController()
        self.audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)
    }

    func start() {
        self.clearBoard()

        targetSide = ceil(screenWidth / CGFloat(MaxTargetsPerRow)) - TargetMargin
        tileSide = ceil(screenWidth / CGFloat(MaxLettersPerRow)) - TileMargin

        if let boardCacheForWord = boardCache[word] {
            loadBoardFromCache(boardCacheForWord)
        } else {
            generateNewBoard()
        }
    }

    private func loadBoardFromCache(_ boardCacheForWord: BoardCache) {
        tiles = boardCacheForWord.tiles
        fixedTiles = boardCacheForWord.fixedTiles
        targets = boardCacheForWord.targets
        hudView.lettersButton.isEnabled = boardCacheForWord.isLettersHintDisabled

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

    private func generateNewBoard() {
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

    private func saveBoardToCache() {
        boardCache[word] = BoardCache(
                tiles: tiles,
                fixedTiles: fixedTiles,
                targets: targets,
                isLettersHintDisabled: hudView.lettersButton.isEnabled
                )
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

    @objc func tileTapped(_ sender: UITapGestureRecognizer) {
        let tile = sender.view as! TileView

        if (tile.isFixed) {
            return
        }

        if (!tile.isPlaced) {
            var foundTarget: TargetView? = nil
            for target in targets {
                if !target.isOccupied {
                    foundTarget = target
                    break
                }
            }

            if let target = foundTarget {
                moveTileToTarget(tile, target)
            }
        } else {
            removeTileFromTarget(tile)
        }
    }

    func moveTileToTarget(_ tile: TileView, _ target: TargetView, _ isForSolve: Bool = false) {
        target.isOccupied = true
        tile.isPlaced = true
        tile.placedOnTarget = target

        gameView.bringSubview(toFront: tile)
        let duration = isForSolve ? 0.6 : 0.3

        UIView.animate(withDuration: duration,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {
                    tile.center = target.center
                }, completion: { (value: Bool) in
                    if (tile.isFixed) {
                        UIView.transition(with: tile, duration: 0.3, options: .transitionCrossDissolve,
                                animations: {
                                    tile.updateBackground()
                                }, completion: { (value: Bool) in
                            self.placeTile(tile, target: target)
                            self.checkForSuccess(isForSolve)
                        })
                    } else {
                        self.placeTile(tile, target: target)
                        self.checkForSuccess(isForSolve)
                    }
                })
    }

    func fixTileOnTarget(_ tile: TileView, _ target: TargetView) {
        tile.isFixed = true
        target.isOccupied = true
        target.isFixed = true
        tile.isPlaced = true
        tile.placedOnTarget = target
        self.placeTile(tile, target: target)
    }

    func clearTarget(_ target: TargetView) {
        for tile in tiles {
            if (tile.placedOnTarget == target) {
                removeTileFromTarget(tile)
                return
            }
        }
    }

    func removeTileFromTarget(_ tile: TileView) {
        tile.placedOnTarget?.isOccupied = false
        tile.placedOnTarget?.isMatched = false
        tile.placedOnTarget = nil
        tile.isPlaced = false
        tile.isMatched = false

        gameView.bringSubview(toFront: tile)

        UIView.animate(withDuration: 0.3,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {
                    tile.center = tile.originalCenter
                }, completion: {
            (value: Bool) in
        })
    }

    func placeTile(_ tile: TileView, target: TargetView) {
        if String(target.letter).uppercased() == String(tile.letter).uppercased() {
            target.isMatched = true
            tile.isMatched = true
        }

        /*UIView.animate(withDuration: 0.3,
                delay: 0.00,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {
                    tile.center = target.center
                })*/

        /*if (!tile.isFixed) {
            let explode = ExplodeView(frame: CGRect(x: tile.center.x, y: tile.center.y, width: 10, height: 10))
            tile.superview?.addSubview(explode)
            tile.superview?.sendSubview(toBack: explode)
        }*/
    }



    func checkForSuccess(_ isForSolve: Bool = false) {
        if (isFinished) {
            return
        }

        for target in targets {
            if !target.isMatched {
                return
            }
        }

        isFinished = true

        var hasNotFixed = false
        for tile in self.tiles {
            if (tile.isMatched && !tile.isFixed) {
                hasNotFixed = true
            }
        }

        if (hasNotFixed) {
            UIView.transition(with: gameView, duration: 0.2, options: .transitionCrossDissolve,
                    animations: {
                        for tile in self.tiles {
                            if (tile.isMatched && !tile.isFixed) {
                                tile.isFixed = true
                                tile.updateBackground()
                            }
                        }
                    }, completion: { (value: Bool) in
                        self.onWordSolved(self.word)
            })
        } else {
            self.onWordSolved(self.word)
        }

        //hud.hintButton.isEnabled = false

        //the anagram is completed!
        //audioController.playEffect(SoundWin)

        // win animation
        /*let firstTarget = targets[0]
        let startX: CGFloat = 0

        let endX: CGFloat = gameView.bounds.size.width + 300
        let startY = firstTarget.center.y

        let stars = StardustView(frame: CGRect(x: startX, y: startY, width: 10, height: 10))
        gameView.addSubview(stars)
        gameView.sendSubview(toBack: stars)

        UIView.animate(withDuration: 3.0,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {
                    stars.center = CGPoint(x: endX, y: startY)
                }, completion: {
            (value: Bool) in
            //game finished
            stars.removeFromSuperview()

            //when animation is finished, show menu
            self.clearBoard()
            self.onWordSolved(self.word)
        })*/

        /*if (isForSolve) {
            usleep(1000 * 100)
        }*/
    }

    @objc func actionHint() {
        for target in targets {
            if !target.isFixed {
                useHintForTarget(target)
                break
            }
        }

        saveBoardToCache()
    }

    @objc func actionSolve() {
        for target in targets {
            if !target.isFixed {
                useHintForTarget(target, isForSolve: true)
            }
        }
    }

    @objc func actionLetters() {
        showLetters()
        saveBoardToCache()
    }

    private func showLetters() {
        if ((cipherType == .shuffle) && (cipherDifficulty == .hard)) {
            //highlight first and last letter
            showLetterForTarget(targets.first!)

            if (word.getCharCount() > 2) {
                showLetterForTarget(targets.last!)
            }
        } else {
            for target in targets {
                if !target.isFixed {
                    showLetterForTarget(target)
                }
            }
        }

        hudView.lettersButton.isEnabled = false
        hudView.lettersButton.alpha = 0.6
    }

    private func showLetterForTarget(_ foundTarget: TargetView) {
        var foundTile: TileView? = nil
        for tile in tiles {
            if !tile.isFixed && !tile.isPartOfWord && tile.letter == foundTarget.letter {
                foundTile = tile
                break
            }
        }

        if let tile = foundTile {
            tile.isPartOfWord = true

            UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions.transitionCrossDissolve,
                    animations: {
                        tile.updateBackground()
                    })
        }
    }

    @objc func useHintForTarget(_ foundTarget: TargetView, isForSolve: Bool = false) {
        var foundTile: TileView? = nil
        for tile in tiles {
            if !tile.isFixed && tile.letter == foundTarget.letter {
                foundTile = tile
                break
            }
        }

        if (foundTile == nil) {
            return
        }

        if (foundTile!.placedOnTarget == foundTarget) {
            fixTileOnTarget(foundTile!, foundTarget)

            UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions.curveEaseOut,
                    animations: {
                        foundTile!.updateBackground()
                    })
            return
        }

        if (foundTarget.isOccupied) {
            clearTarget(foundTarget)
        }

        if (foundTile!.isPlaced) {
            removeTileFromTarget(foundTile!)
        }

        fixTileOnTarget(foundTile!, foundTarget)
        moveTileToTarget(foundTile!, foundTarget, isForSolve)
    }

    private func clearBoard() {
        isFinished = false
        fixedTiles.removeAll(keepingCapacity: false)
        tiles.removeAll(keepingCapacity: false)
        targets.removeAll(keepingCapacity: false)

        for view in gameView.subviews {
            view.removeFromSuperview()
        }

        hudView.lettersButton.isEnabled = true
        hudView.lettersButton.alpha = 1
    }

    public func clearPlacedTiles() {
        for tile in tiles {
            removeTileFromTarget(tile)
        }
    }

    public func clearCache() {
        boardCache = [:]
    }

    public func setNewWord(_ newWord: Word) {
        if (self.word != nil && !isFinished) {
            checkForSuccess()
        }

        self.word = newWord
    }
}
