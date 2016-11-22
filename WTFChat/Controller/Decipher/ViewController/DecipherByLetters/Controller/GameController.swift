import Foundation
import UIKit
import Localize_Swift

class GameController {
    var gameView: UIView!
    var word: Word!

    private var tiles = [TileView]()
    private var fixedTiles = [TileView]()
    fileprivate var targets = [TargetView]()

    private var isFinished = false

    var hudView: HUDView! {
        didSet {
            //connect the Hint button
            hudView.hintButton.addTarget(self, action: #selector(GameController.actionHint), for: .touchUpInside)
            hudView.solveButton.addTarget(self, action: #selector(GameController.actionSolve), for: .touchUpInside)
        }
    }

    private var generatedLettersCache = [Word: String]()

    fileprivate var audioController: AudioController

    var onWordSolved: ((_: Word) -> ())!

    init() {
        self.audioController = AudioController()
        self.audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)
    }

    func start() {
        self.clearBoard()

        var wordText = word.text

        let wordlength = wordText.characters.count

        let screenWidth = gameView.bounds.size.width

        let targetSide = ceil(screenWidth / CGFloat(MaxTargetsPerRow)) - TargetMargin
        let tileSide = ceil(screenWidth / CGFloat(MaxLettersPerRow)) - TileMargin

        targets = []

        //create targets
        for position in 0 ..< wordText.characters.count {
            let target = TargetView(letter: Character(wordText[position]), sideLength: targetSide)

            if (wordlength <= MaxTargetsPerRow) {
                let xTargetOffset = (screenWidth - CGFloat(wordlength) * (targetSide + TargetMargin)) / 2.0 + targetSide / 2.0
                target.center = CGPoint(x: xTargetOffset + CGFloat(position) * (targetSide + TargetMargin), y: targetSide / 2 + VerticalPadding)
            } else {
                let lettersInFirstRow = wordlength / 2 + (wordlength % 2)
                let lettersInSecondRow = wordlength / 2

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
            targets.append(target)
        }

        fixedTiles = []
        for position in 0 ..< wordText.characters.count {
            if (word.fullCipheredText[position] == ".") {
                continue
            }

            let tile = TileView(letter: Character(wordText[position]), sideLength: tileSide)
            tile.center = targets[position].center
            fixedTiles.append(tile)
            gameView.addSubview(tile)
            fixTileOnTarget(tile, targets[position])
            tile.updateBackground()
        }

        tiles = []
        let letters = generateLetters()

        for tileIndex in 0 ..< letters.characters.count {
            let tile = TileView(letter: Character(letters[tileIndex]), sideLength: tileSide)

            var targetOffset: CGFloat

            if (wordlength <= MaxTargetsPerRow) {
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

            tiles.append(tile)
            gameView.addSubview(tile)

            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tileTapped(_:)))
            tile.addGestureRecognizer(tap)
        }
    }

    private func generateLetters() -> String {
        if let letters = generatedLettersCache[word] {
            return letters
        }

        var result = word.hidedLetters
        let needLetters = LettersOnBoard - result.characters.count

        for _ in 0 ..< needLetters {
            result += TextLanguage.getRandomLetter()
        }

        result = result.shuffle
        generatedLettersCache[word] = result

        return result
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
                    tile.updateBackground()
                    tile.center = target.center
                }, completion: {
            (value: Bool) in

            self.placeTile(tile, target: target)

            self.checkForSuccess(isForSolve)
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
            UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions.curveEaseOut,
                    animations: {
                        for tile in self.tiles {
                            if (tile.isMatched && !tile.isFixed) {
                                tile.isFixed = true
                                tile.updateBackground()
                            }
                        }
                    },
                    completion: { (value: Bool) in
                        usleep(1000 * 100)
                        self.onWordSolved(self.word)
                    })
        } else {
            usleep(1000 * 100)
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

    //the user pressed the hint button
    @objc func actionHint() {
        for target in targets {
            if !target.isFixed {
                useHintForTarget(target)
                break
            }
        }
    }

    //the user pressed the hint button
    @objc func actionSolve() {
        for target in targets {
            if !target.isFixed {
                useHintForTarget(target, isForSolve: true)
            }
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

    func clearBoard() {
        isFinished = false
        fixedTiles.removeAll(keepingCapacity: false)
        tiles.removeAll(keepingCapacity: false)
        targets.removeAll(keepingCapacity: false)

        for view in gameView.subviews {
            view.removeFromSuperview()
        }
    }

    func clearPlacedTiles() {
        for tile in tiles {
            removeTileFromTarget(tile)
        }
    }

    func clearCache() {
        generatedLettersCache = [:]
    }
}
