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
    let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)

    var gameView: UIView!
    var word: Word!
    var cipherType: CipherType!
    var cipherDifficulty: CipherDifficulty!

    var tiles = [TileView]()
    var fixedTiles = [FixedTileView]()
    var targets = [TargetView]()

    var isFinished = false
    var tileSide: CGFloat!
    var targetSide: CGFloat!

    var boardCache = [Word: BoardCache]()

    var hudView: HUDView! {
        didSet {
            //connect the Hint button
            hudView.hintButton.addTarget(self, action: #selector(GameController.actionHint), for: .touchUpInside)
            hudView.solveButton.addTarget(self, action: #selector(GameController.actionSolve), for: .touchUpInside)
            hudView.lettersButton.addTarget(self, action: #selector(GameController.actionLetters), for: .touchUpInside)
        }
    }

    private var audioController: AudioController

    var onWordSolved: ((_: Word) -> ())!
    var getMoreWtf: (() -> ())!

    var wordLength: Int {
        return word.text.characters.count
    }

    var wordText: String {
        return word.text
    }

    var screenWidth: CGFloat {
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

    func showLetterForTarget(_ foundTarget: TargetView) {
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
