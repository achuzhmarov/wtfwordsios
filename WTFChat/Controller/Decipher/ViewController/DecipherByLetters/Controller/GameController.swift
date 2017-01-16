import Foundation
import UIKit
import Localize_Swift

class BoardCache {
    var tiles = [TileView]()
    var fixedTiles = [FixedTileView]()
    var targets = [TargetView]()
    var isLettersHintDisabled = false

    init(tiles: [TileView], fixedTiles: [FixedTileView], targets: [TargetView], isLettersHintUsed: Bool) {
        self.tiles = tiles
        self.fixedTiles = fixedTiles
        self.targets = targets
        self.isLettersHintDisabled = isLettersHintUsed
    }
}

class GameController {
    let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

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

    var hudView: HUDView!

    var animationInProgressCount = 0

    var onWordSolved: ((_: Word) -> ())!
    var getMoreWtf: (() -> ())!
    var useWtf: ((_: Int) -> ())!
    var showRemoveLettersHint: (() -> ())!

    var wordLength: Int {
        return word.text.characters.count
    }

    var wordText: String {
        return word.text
    }

    var screenHeight: CGFloat {
        return gameView.bounds.size.height
    }

    var screenWidth: CGFloat {
        return gameView.bounds.size.width
    }

    func updateHud() {
        var isLettersHintDisabled = false
        if let isEnabled = hudView.lettersButton?.isEnabled {
            isLettersHintDisabled = !isEnabled
        }

        hudView.tileSide = tileSide
        hudView.update()
        connectHudButtons()

        if (isLettersHintDisabled) {
            disableLettersHintButton()
        }
    }

    private func connectHudButtons() {
        //connect the Hint button
        hudView.hintButton?.addTarget(self, action: #selector(self.actionHint), for: .touchUpInside)
        hudView.solveButton?.addTarget(self, action: #selector(self.actionSolve), for: .touchUpInside)
        hudView.lettersButton?.addTarget(self, action: #selector(self.actionLetters), for: .touchUpInside)
    }

    func start() {
        clearBoard()

        let widthTileSide = ceil(screenWidth / CGFloat(MaxLettersPerRow))
        let heightTileSide = ceil(screenHeight / MaxTilesVertical) - VerticalPadding

        tileSide = min(widthTileSide, heightTileSide)
        targetSide = min(ceil(screenWidth / CGFloat(MaxTargetsPerRow)) - TargetMargin, tileSide)

        updateHud()

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
        placeTile(tile, target: target)

        gameView.bringSubview(toFront: tile)
        let duration = isForSolve ? 0.6 : 0.3

        animationInProgressCount += 1

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
                            //self.placeTile(tile, target: target)
                            self.animationInProgressCount -= 1
                            self.checkForSuccess(self.word)
                        })
                    } else {
                        //self.placeTile(tile, target: target)
                        self.animationInProgressCount -= 1
                        self.checkForSuccess(self.word)
                    }
                })
    }

    func fixTileOnTarget(_ tile: TileView, _ target: TargetView) {
        tile.isFixed = true
        target.isFixed = true
        placeTile(tile, target: target)
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
        target.isOccupied = true
        tile.isPlaced = true
        tile.placedOnTarget = target

        if String(target.letter).uppercased() == String(tile.letter).uppercased() {
            target.isMatched = true
            tile.isMatched = true
        }
    }

    //word can be updated while checking - can't use class variable
    func checkForSuccess(_ checkedWord: Word) {
        if (isFinished || (animationInProgressCount > 0)) {
            return
        }

        for target in targets {
            if !target.isMatched {
                checkForRemoveLettersHint()
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
                        self.onWordSolved(checkedWord)
            })
        } else {
            self.onWordSolved(checkedWord)
        }
    }

    private func checkForRemoveLettersHint() {
        if (guiDataService.hasWrongLettersHint()) {
            return
        }

        for target in targets {
            if !target.isOccupied {
                return
            }
        }

        showRemoveLettersHint()
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
            animationInProgressCount = 0
            checkForSuccess(self.word)
        }

        self.word = newWord
    }

    //TODO - Not in +Hints extension because of the tutorial
    func showHintConfirmAlert(_ hintType: HintType, completion: @escaping () -> ()) {
        let wtf = currentUserService.getUserWtf()

        if (wtf < hintType.costInWtf) {
            showNoWtfDialog(wtf: wtf)
            return
        } else {
            showHintConfirm(wtf: wtf, hintType: hintType, completion: completion)
        }
    }

    //TODO  - Not in +Hints extension because of the tutorial
    private func showNoWtfDialog(wtf: Int) {
        WTFTwoButtonsAlert.show("WTF remained:".localized() + " " + String(wtf),
                message: "You don't have enough WTF. Want to get more?".localized(),
                firstButtonTitle: "Get more".localized()) { () -> Void in
            self.getMoreWtf()
        }
    }

    //TODO  - Not in +Hints extension because of the tutorial
    func showHintConfirm(wtf: Int, hintType: HintType, completion: @escaping () -> () ) {
        WTFTwoButtonsAlert.show("WTF remained:".localized() + " " + String(wtf),
                message: hintType.details.localized(),
                firstButtonTitle: "Use".localized() + " " + String(hintType.costInWtf) + " " + "WTF".localized()) { () -> Void in

            DispatchQueue.main.async(execute: {
                self.useWtf(hintType.costInWtf)
                completion()
            })
        }
    }
}
