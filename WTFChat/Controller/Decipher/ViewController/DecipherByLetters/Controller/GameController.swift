import Foundation
import UIKit

class GameController {
    var gameView: UIView!
    var word: Word!

    private var tiles = [TileView]()
    fileprivate var targets = [TargetView]()

    /*var hud:HUDView! {
      didSet {
        //connect the Hint button
        hud.hintButton.addTarget(self, action: #selector(GameController.actionHint), for:.touchUpInside)
        hud.hintButton.isEnabled = false
      }
    }*/

    //stopwatch variables
    private var secondsLeft: Int = 0
    private var timer: Timer?

    private var data = GameData()

    fileprivate var audioController: AudioController

    var onWordSolved: ((_ : Word) -> ())!

    init() {
        self.audioController = AudioController()
        self.audioController.preloadAudioEffects(effectFileNames: AudioEffectFiles)
    }

    func start() {
        self.clearBoard()

        var wordText = word.text

        let maxLettersPerRow = 7
        let maxTargetsPerRow = 10

        let wordlength = wordText.characters.count
        print("word[\(wordlength)]: \(wordText)")

        let screenWidth = gameView.bounds.size.width

        let targetSide = ceil(screenWidth / CGFloat(maxTargetsPerRow)) - TileMargin
        let tileSide = ceil(screenWidth / CGFloat(maxLettersPerRow)) - TileMargin

        targets = []

        //create targets
        var index = 0
        for letter in wordText.characters {
            let target = TargetView(letter: letter, sideLength: targetSide)

            if (wordlength <= maxTargetsPerRow) {
                let xTargetOffset = (screenWidth - CGFloat(wordlength) * (targetSide + TileMargin)) / 2.0 + targetSide / 2.0
                target.center = CGPoint(x: xTargetOffset + CGFloat(index) * (targetSide + TileMargin), y: targetSide / 2 + 8)
            } else {
                let lettersInFirstRow = wordlength / 2 + (wordlength % 2)
                let lettersInSecondRow = wordlength / 2

                let xTargetIndexOffset = CGFloat(index % lettersInFirstRow) * (targetSide + TileMargin)

                if (index < lettersInFirstRow) {
                    let xTargetOffset = (screenWidth - CGFloat(lettersInFirstRow) * (targetSide + TileMargin)) / 2.0 + targetSide / 2.0
                    let yTargetOffset = targetSide / 2 + 8
                    target.center = CGPoint(x: xTargetOffset + xTargetIndexOffset, y: yTargetOffset)
                } else {
                    let xTargetOffset = (screenWidth - CGFloat(lettersInSecondRow) * (targetSide + TileMargin)) / 2.0 + targetSide / 2.0
                    let yTargetOffset = targetSide / 2 + 8 + (targetSide + 8)
                    target.center = CGPoint(x: xTargetOffset + xTargetIndexOffset, y: yTargetOffset)
                }
            }

            gameView.addSubview(target)
            targets.append(target)

            index += 1
        }

        tiles = []

        index = 0
        for letter in wordText.characters {
            let tile = TileView(letter: letter, sideLength: tileSide)

            var targetOffset: CGFloat

            if (wordlength <= maxTargetsPerRow) {
                targetOffset = targetSide
            } else {
                targetOffset = targetSide * 1.5 + 8
            }

            if (index < maxLettersPerRow) {
                let xLetterOffset = (screenWidth - CGFloat(min(wordlength, maxLettersPerRow)) * (tileSide + TileMargin)) / 2.0 + tileSide / 2.0
                tile.center = CGPoint(x: xLetterOffset + CGFloat(index) * (tileSide + TileMargin), y: targetOffset + (tileSide + 8))
            } else if (index < (2 * maxLettersPerRow)) {
                let xLetterOffset = (screenWidth - CGFloat(min(wordlength - maxLettersPerRow, maxLettersPerRow)) * (tileSide + TileMargin)) / 2.0 + tileSide / 2.0
                tile.center = CGPoint(x: xLetterOffset + CGFloat(index % maxLettersPerRow) * (tileSide + TileMargin), y: targetOffset + (tileSide + 8) * 2)
            } else {
                let xLetterOffset = (screenWidth - CGFloat(min(wordlength - 2 * maxLettersPerRow, maxLettersPerRow)) * (tileSide + TileMargin)) / 2.0 + tileSide / 2.0
                tile.center = CGPoint(x: xLetterOffset + CGFloat(index % maxLettersPerRow) * (tileSide + TileMargin), y: targetOffset + (tileSide + 8) * 3)
            }

            //tile.randomize()
            tile.dragDelegate = self
            tile.originalCenter = tile.center

            gameView.addSubview(tile)
            tiles.append(tile)

            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tileTapped(_:)))
            tile.addGestureRecognizer(tap)

            index += 1
        }

        //hud.hintButton.isEnabled = true
    }

    @objc func tileTapped(_ sender: UITapGestureRecognizer) {
        let tile = sender.view as! TileView

        if (!tile.isPlaced) {
            moveTileToTarget(tile)
        } else {
            removeTileFromTarget(tile)
        }
    }

    func moveTileToTarget(_ tile: TileView) {
        var foundTarget: TargetView? = nil
        for target in targets {
            if !target.isOccupied {
                foundTarget = target
                break
            }
        }

        //ensure there is a matching tile and target
        if let target = foundTarget {
            target.isOccupied = true
            tile.isPlaced = true
            tile.placedOnTarget = target

            //5 don't want the tile sliding under other tiles
            gameView.bringSubview(toFront: tile)

            //6 show the animation to the user
            UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions.curveEaseOut,
                    animations: {
                        tile.center = target.center
                    }, completion: {
                (value: Bool) in

                //7 adjust view on spot
                self.placeTile(tile, targetView: target)

                //8 re-enable the button
                //self.hud.hintButton.isEnabled = true

                //9 check for finished game
                self.checkForSuccess()
            })
        }
    }

    func removeTileFromTarget(_ tile: TileView) {
        tile.placedOnTarget?.isOccupied = false
        tile.placedOnTarget?.isMatched = false
        tile.placedOnTarget = nil
        tile.isPlaced = false
        tile.isMatched = false

        gameView.bringSubview(toFront: tile)

        //6 show the animation to the user
        UIView.animate(withDuration: 0.3,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {
                    tile.center = tile.originalCenter
                }, completion: {
            (value: Bool) in
        })
    }

    func placeTile(_ tileView: TileView, targetView: TargetView) {
        if targetView.letter == tileView.letter {
            targetView.isMatched = true
            tileView.isMatched = true
        }

        //tileView.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.35,
                delay: 0.00,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {
                    tileView.center = targetView.center
                    tileView.transform = CGAffineTransform.identity
                },
                completion: {
                    (value: Bool) in
                    //targetView.isHidden = true
                })

        let explode = ExplodeView(frame: CGRect(x: tileView.center.x, y: tileView.center.y, width: 10, height: 10))
        tileView.superview?.addSubview(explode)
        tileView.superview?.sendSubview(toBack: explode)
    }


    func checkForSuccess() {
        for targetView in targets {
            //no success, bail out
            if !targetView.isMatched {
                return
            }
        }
        print("Game Over!")

        //hud.hintButton.isEnabled = false

        //the anagram is completed!
        audioController.playEffect(SoundWin)

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

        self.onWordSolved(self.word)
    }

    //the user pressed the hint button
    @objc func actionHint() {
        //1
        //hud.hintButton.isEnabled = false

        //2
        //data.points -= level.pointsPerTile / 2
        //hud.gamePoints.setValue(data.points, duration: 1.5)

        //3 find the first unmatched target and matching tile
        var foundTarget: TargetView? = nil
        for target in targets {
            if !target.isMatched {
                foundTarget = target
                break
            }
        }

        //4 find the first tile matching the target
        var foundTile: TileView? = nil
        for tile in tiles {
            if !tile.isMatched && tile.letter == foundTarget?.letter {
                foundTile = tile
                break
            }
        }

        //ensure there is a matching tile and target
        if let target = foundTarget, let tile = foundTile {

            //5 don't want the tile sliding under other tiles
            gameView.bringSubview(toFront: tile)

            //6 show the animation to the user
            UIView.animate(withDuration: 1.5,
                    delay: 0.0,
                    options: UIViewAnimationOptions.curveEaseOut,
                    animations: {
                        tile.center = target.center
                    }, completion: {
                (value: Bool) in

                //7 adjust view on spot
                self.placeTile(tile, targetView: target)

                //8 re-enable the button
                //self.hud.hintButton.isEnabled = true

                //9 check for finished game
                self.checkForSuccess()

            })
        }
    }

    //clear the tiles and targets
    func clearBoard() {
        tiles.removeAll(keepingCapacity: false)
        targets.removeAll(keepingCapacity: false)

        for view in gameView.subviews {
            view.removeFromSuperview()
        }
    }

}

extension GameController: TileDragDelegateProtocol {
    //a tile was dragged, check if matches a target
    func tileView(_ tileView: TileView, didDragToPoint point: CGPoint) {
        var targetView: TargetView?
        for tv in targets {
            if tv.frame.contains(point) && !tv.isMatched {
                targetView = tv
                break
            }
        }

        //1 check if target was found
        if let targetView = targetView {

            //2 check if letter matches
            if targetView.letter == tileView.letter {

                //3
                self.placeTile(tileView, targetView: targetView)

                //more stuff to do on success here

                audioController.playEffect(SoundDing)

                //give points
                //data.points += level.pointsPerTile
                //hud.gamePoints.setValue(data.points, duration: 0.5)

                //check for finished game
                self.checkForSuccess()

            } else {

                //4
                //1
                //tileView.randomize()

                //2
                UIView.animate(withDuration: 0.35,
                        delay: 0.00,
                        options: UIViewAnimationOptions.curveEaseOut,
                        animations: {
                            tileView.center = CGPoint(x: tileView.center.x + CGFloat(randomNumber(minX: 0, maxX: 40) - 20),
                                    y: tileView.center.y + CGFloat(randomNumber(minX: 20, maxX: 30)))
                        },
                        completion: nil)

                //more stuff to do on failure here

                audioController.playEffect(SoundWrong)

                //take out points
                //data.points -= level.pointsPerTile/2
                //hud.gamePoints.setValue(data.points, duration: 0.25)
            }
        }

    }


}
