import Foundation

extension DecipherViewController {

    func start() {
        bottomButtonsView.hidden = true
        resultView.hidden = true
        resultViewHeightConstraint.constant = 0
        expGainView.removeView()

        NSLayoutConstraint.activateConstraints([bottomViewWordsPaddingContraint])

        self.navigationItem.setHidesBackButton(true, animated:true)

        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                selector: #selector(DecipherViewController.tick), userInfo: nil, repeats: false)

        bottomView.hidden = false
        bottomViewHeightConstraint.constant = initialBottomViewHeightConstraint

        topTimerLabel.hidden = false
        topStopImage.hidden = false
        topCategoryLabel.hidden = false
        //wordsTableView.hidden = false

        wordsTableView.setNewMessage(message)

        guessTextField.becomeFirstResponder()

        layoutTopView()

        isStarted = true
        isOvered = false

        UIView.setAnimationsEnabled(true)

        wordsTableView.alpha = 0
        timerView.alpha = 0
        bottomView.alpha = 0

        UIView.animateWithDuration(0.3, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
            self.timerView.alpha = 1
            self.bottomView.alpha = 1
        }, completion: nil)
    }

    func tick() {
        if (isOvered) {
            return
        }

        if (isPaused) {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                    selector: #selector(DecipherViewController.tick), userInfo: nil, repeats: false)

            return
        }

        timer.tick()

        topTimerLabel.text = timer.getTimeString()

        if (timer.isFinished()) {
            dispatch_async(dispatch_get_main_queue(), {
                self.gameOver()
            })
        } else {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                    selector: #selector(DecipherViewController.tick), userInfo: nil, repeats: false)

            if (timer.isRunningOfTime()) {
                topTimerLabel.textColor = UIColor.redColor()

                UIView.animateWithDuration(0.5, delay: 0,
                        options: [.Autoreverse, .Repeat, .AllowUserInteraction], animations: {
                    self.topTimerLabel.alpha = 0.1
                }, completion: nil)
            } else if (timer.isLastSecond()) {
                topTimerLabel.layer.removeAllAnimations()
                topTimerLabel.alpha = 1
            }
        }
    }

    func gameOver() {
        messageCipherService.failed(message)
        message.timerSecs = timer.seconds

        bottomView.hidden = true
        bottomViewHeightConstraint.constant = 0

        topPaddingConstraint.constant = initialTopPaddingConstraintConstant

        bottomButtonsView.hidden = false
        NSLayoutConstraint.deactivateConstraints([bottomViewWordsPaddingContraint])
        dismissKeyboard()

        UIView.setAnimationsEnabled(true)

        wordsTableView.updateMessage(message)

        showResult()

        isOvered = true

        showExpView()

        sendMessageDecipher()

        wordsTableView.alpha = 0
        timerView.alpha = 0
        resultView.alpha = 0
        bottomButtonsView.alpha = 0

        UIView.animateWithDuration(0.3, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
            self.timerView.alpha = 1
            self.resultView.alpha = 1
            self.bottomButtonsView.alpha = 1
        }, completion: nil)
    }

    func showExpView() {
        //TODO - What to do with existing layer? Maybe add another for exp?
        timer.seconds = 0
        topTimerLabel.hidden = true
        topStopImage.hidden = true
        topCategoryLabel.hidden = true

        //init exp gain
        self.expGainView.initView(self.timerView)
    }

    private func showResult() {
        resultView.hidden = false
        resultViewHeightConstraint.constant = resultViewHeightConstraintConstant

        resultLabel.layer.cornerRadius = 12
        resultLabel.textColor = Color.Text

        if (message.getMessageStatus() == .Success) {
            resultLabel.text = SUCCESS_TEXT
            resultLabel.addGradientToLabel(Gradient.Success)
            continueButton.setTitle("Continue", forState: .Normal)

            audioService.playSound("win")
        } else {
            resultLabel.text = FAILED_TEXT
            resultLabel.addGradientToLabel(Gradient.Failed)
            continueButton.setTitle("Retry", forState: .Normal)

            audioService.playSound("lose")
        }
    }
}
