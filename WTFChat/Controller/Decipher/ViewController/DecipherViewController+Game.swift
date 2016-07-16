import Foundation

extension DecipherViewController {

    func start() {
        self.navigationItem.setHidesBackButton(true, animated:true)

        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                selector: #selector(DecipherViewController.tick), userInfo: nil, repeats: false)

        bottomView.hidden = false
        topTimerLabel.hidden = false
        wordsTableView.hidden = false

        startView?.removeFromSuperview()

        wordsTableView.updateMessage(message)

        guessTextField.becomeFirstResponder()

        isStarted = true
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

        navigationItem.rightBarButtonItem = nil
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
            audioService.playSound("win")
        } else {
            resultLabel.text = FAILED_TEXT
            resultLabel.addGradientToLabel(Gradient.Failed)
            audioService.playSound("lose")
        }
    }
}
