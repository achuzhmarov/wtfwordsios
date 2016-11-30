import Foundation

extension GameController {
    @objc func actionHint() {
        showHintConfirmAlert(HintType.letters) {
            self.useHint()
        }
    }

    @objc func actionSolve() {
        showHintConfirmAlert(HintType.letters) {
            self.useSolve()
        }
    }

    @objc func actionLetters() {
        showHintConfirmAlert(HintType.letters) {
            self.useLetters()
        }
    }

    private func showHintConfirmAlert(_ hintType: HintType, completion: @escaping () -> ()) {
        let wtfs = currentUserService.getUserWtfs()

        if (wtfs < hintType.costInWtfs) {
            showNoWtfsDialog(wtfs: wtfs)
            return
        } else {
            showHintConfirm(wtfs: wtfs, hintType: hintType, completion: completion)
        }
    }

    private func showNoWtfsDialog(wtfs: Int) {
        WTFTwoButtonsAlert.show("WTFs remained:".localized() + " " + String(wtfs),
                message: "You don't have enough WTFs to use a hint. Want to get more?".localized(),
                firstButtonTitle: "Get more".localized()) { () -> Void in
            self.getMoreWtfs()
        }
    }

    private func showHintConfirm(wtfs: Int, hintType: HintType, completion: @escaping () -> () ) {
        WTFTwoButtonsAlert.show("WTFs remained:".localized() + " " + String(wtfs),
                message: "",
                firstButtonTitle: "Use a WTF".localized()) { () -> Void in

            DispatchQueue.main.async(execute: {
                self.currentUserService.useWtfs(hintType.costInWtfs)
                completion()
            })
        }
    }

    private func useHint() {
        for target in targets {
            if !target.isFixed {
                useHintForTarget(target)
                break
            }
        }

        saveBoardToCache()
    }

    private func useSolve() {
        for target in targets {
            if !target.isFixed {
                useHintForTarget(target, isForSolve: true)
            }
        }
    }

    private func useLetters() {
        showLetters()
        saveBoardToCache()
    }

    func showLetters() {
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

        disableLettersHintButton()
    }

    func disableLettersHintButton() {
        hudView.lettersButton.isEnabled = false
        hudView.lettersButton.alpha = 0.6
    }

    func enableLettersHintButton() {
        hudView.lettersButton.isEnabled = true
        hudView.lettersButton.alpha = 1
    }

    private func useHintForTarget(_ foundTarget: TargetView, isForSolve: Bool = false) {
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
}
