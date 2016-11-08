import Foundation
import Localize_Swift

class ExpGainView: NSObject {
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

    fileprivate let LEVEL_TEXT = "LEVEL".localized()

    var progressView: UIProgressView?
    var expLabel: UILabel?
    var lvlLabel: UILabel?
    var progressBarTimer: Foundation.Timer?
    var userExp: Int = 0
    var nextLvlExp: Int = 0
    var userLvl: Int = 0

    let lvlTopMargin = CGFloat(8)
    let progressUpdateInterval = 0.1
    let progressUpdateMaxStep = Float(0.125)

    func initView(_ superView: UIView) {
        self.lvlLabel = createLvlLabel(superView, userLvl: currentUserService.getUserLvl())
        self.expLabel = createExpLabel(superView)
        self.progressView = createProgressBar(superView)
        
        userExp = currentUserService.getCurrentLvlExp()
        nextLvlExp = currentUserService.getNextLvlExp()
        userLvl = currentUserService.getUserLvl()
    }
    
    fileprivate func createLvlLabel(_ rootView: UIView, userLvl: Int) -> UILabel {
        //create gauge view
        let lvlLabel = UILabel()
        lvlLabel.text = LEVEL_TEXT + " " + String(userLvl)
        lvlLabel.font = UIFont.init(name: lvlLabel.font.fontName, size: 14)
        lvlLabel.translatesAutoresizingMaskIntoConstraints = false
        lvlLabel.numberOfLines = 1
        lvlLabel.sizeToFit()
        
        rootView.addSubview(lvlLabel)
        
        //add constraints
        let leftConstraint = NSLayoutConstraint(item: lvlLabel, attribute: .leading, relatedBy: .equal, toItem: rootView, attribute: .leading, multiplier: 1, constant: 0)
        rootView.addConstraint(leftConstraint)
        
        let yConstraint = NSLayoutConstraint(item: lvlLabel, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1, constant: lvlTopMargin)
        rootView.addConstraint(yConstraint)
        
        return lvlLabel
    }

    fileprivate func createExpLabel(_ rootView: UIView) -> UILabel {
        //create gauge view
        let expLabel = UILabel()
        expLabel.font = UIFont.init(name: expLabel.font.fontName, size: 14)
        expLabel.translatesAutoresizingMaskIntoConstraints = false
        expLabel.numberOfLines = 1
        expLabel.sizeToFit()
        
        rootView.addSubview(expLabel)
        
        //add constraints
        let rightConstraint = NSLayoutConstraint(item: expLabel, attribute: .trailing, relatedBy: .equal, toItem: rootView, attribute: .trailing, multiplier: 1, constant: 0)
        rootView.addConstraint(rightConstraint)
        
        let yConstraint = NSLayoutConstraint(item: expLabel, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1, constant: lvlTopMargin)
        rootView.addConstraint(yConstraint)
        
        return expLabel
    }
    
    fileprivate func createProgressBar(_ rootView: UIView) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
        progressView.progress = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(progressView)
        
        let leftConstraint = NSLayoutConstraint(item: progressView, attribute: .leading, relatedBy: .equal, toItem: rootView, attribute: .leading, multiplier: 1, constant: 0)
        rootView.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: progressView, attribute: .trailing, relatedBy: .equal, toItem: rootView, attribute: .trailing, multiplier: 1, constant: 0)
        rootView.addConstraint(rightConstraint)
        
        let yConstraint = NSLayoutConstraint(item: progressView, attribute: .bottom, relatedBy: .equal, toItem: rootView, attribute: .bottom, multiplier: 1, constant: 0)
        rootView.addConstraint(yConstraint)

        return progressView
    }

    func runProgress(_ earnedExp: Int) {
        if (progressView == nil) {
            NSLog("call to runProgress while no initView")
            return
        }

        if (earnedExp == 0) {
            setFinishedProgress()
            return
        }

        userExp += earnedExp

        DispatchQueue.main.async(execute: {
            self.progressBarTimer?.invalidate()
            
            self.progressBarTimer = Foundation.Timer.scheduledTimer(timeInterval: self.progressUpdateInterval, target: self,
                selector: #selector(ExpGainView.updateProgress), userInfo: nil, repeats: true)
        })

        expLabel?.text = "+\(String(earnedExp))XP"
    }

    fileprivate func setFinishedProgress() {
        let targetProgress = getTargetProgress()
        self.progressView?.setProgress(targetProgress, animated: false)
    }

    fileprivate func getTargetProgress() -> Float {
        var targetProgress = Float(userExp) / Float(nextLvlExp)
        if (targetProgress > 1) {
            targetProgress = 1.0
        }

        return targetProgress
    }

    func updateProgress() {
        if (progressView == nil) {
            NSLog("call to updateProgress while no myInit")
            return
        }

        let targetProgress = getTargetProgress()
        
        if (progressView!.progress >= targetProgress) {
            self.progressBarTimer?.invalidate()
            
            if (progressView!.progress == 1) {
                let newUserLvl = currentUserService.getUserLvl()

                DispatchQueue.main.async {
                    usleep(1000 * 500)
                    
                    UIView.animate(withDuration: 1,
                        animations: {
                            self.lvlLabel?.text = self.LEVEL_TEXT + " " + String(newUserLvl)
                        },
                        completion: nil
                    )
                }
            }
        } else {
            var progressStep = targetProgress - self.progressView!.progress
            if (progressStep > self.progressUpdateMaxStep) {
                progressStep = self.progressUpdateMaxStep
            }
            
            DispatchQueue.main.async {
                UIView.animate(
                    withDuration: 1,
                    animations: {
                        self.progressView?.setProgress(
                            self.progressView!.progress + progressStep, animated: true
                        )
                    }
                )
            }
        }
    }

    func clearView() {
        progressView?.removeFromSuperview()
        expLabel?.removeFromSuperview()
        lvlLabel?.removeFromSuperview()
    }
}
