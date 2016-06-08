//
//  ExpGainView.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ExpGainView: NSObject {
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

    var progressView: UIProgressView?
    var expLabel: UILabel?
    var lvlLabel: UILabel?
    var progressBarTimer: NSTimer?
    var userExp: Int = 0
    var nextLvlExp: Int = 0
    
    let lvlTopMargin = CGFloat(8)
    let progressUpdateInterval = 0.1
    let progressUpdateMaxStep = Float(0.125)
    
    func initView(superView: UIView) {
        self.lvlLabel = createLvlLabel(superView, userLvl: currentUserService.getUserLvl())
        self.expLabel = createExpLabel(superView)
        self.progressView = createProgressBar(superView)
        
        userExp = currentUserService.getCurrentLvlExp()
        nextLvlExp = currentUserService.getNextLvlExp()
    }
    
    func createLvlLabel(rootView: UIView, userLvl: Int) -> UILabel {
        //create gauge view
        let lvlLabel = UILabel()
        lvlLabel.text = "LEVEL \(String(userLvl))"
        lvlLabel.font = UIFont(name: lvlLabel.font.fontName, size: 14)
        lvlLabel.translatesAutoresizingMaskIntoConstraints = false
        lvlLabel.numberOfLines = 1
        lvlLabel.sizeToFit()
        
        rootView.addSubview(lvlLabel)
        
        //add constraints
        let leftConstraint = NSLayoutConstraint(item: lvlLabel, attribute: .Leading, relatedBy: .Equal, toItem: rootView, attribute: .Leading, multiplier: 1, constant: 0)
        rootView.addConstraint(leftConstraint)
        
        let yConstraint = NSLayoutConstraint(item: lvlLabel, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: lvlTopMargin)
        rootView.addConstraint(yConstraint)
        
        return lvlLabel
    }
    
    func createExpLabel(rootView: UIView) -> UILabel {
        //create gauge view
        let expLabel = UILabel()
        expLabel.font = UIFont(name: expLabel.font.fontName, size: 14)
        expLabel.translatesAutoresizingMaskIntoConstraints = false
        expLabel.numberOfLines = 1
        expLabel.sizeToFit()
        
        rootView.addSubview(expLabel)
        
        //add constraints
        let rightConstraint = NSLayoutConstraint(item: expLabel, attribute: .Trailing, relatedBy: .Equal, toItem: rootView, attribute: .Trailing, multiplier: 1, constant: 0)
        rootView.addConstraint(rightConstraint)
        
        let yConstraint = NSLayoutConstraint(item: expLabel, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: lvlTopMargin)
        rootView.addConstraint(yConstraint)
        
        return expLabel
    }
    
    func createProgressBar(rootView: UIView) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
        progressView.progress = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(progressView)
        
        let leftConstraint = NSLayoutConstraint(item: progressView, attribute: .Leading, relatedBy: .Equal, toItem: rootView, attribute: .Leading, multiplier: 1, constant: 0)
        rootView.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: progressView, attribute: .Trailing, relatedBy: .Equal, toItem: rootView, attribute: .Trailing, multiplier: 1, constant: 0)
        rootView.addConstraint(rightConstraint)
        
        let yConstraint = NSLayoutConstraint(item: progressView, attribute: .Bottom, relatedBy: .Equal, toItem: rootView, attribute: .Bottom, multiplier: 1, constant: 0)
        rootView.addConstraint(yConstraint)

        return progressView
    }
    
    func runProgress(earnedExp: Int) {
        if (progressView == nil) {
            NSLog("call to runProgress while no myInit")
            return
        }
        
        self.userExp += earnedExp
        
        dispatch_async(dispatch_get_main_queue(), {
            self.progressBarTimer?.invalidate()
            
            self.progressBarTimer = NSTimer.scheduledTimerWithTimeInterval(self.progressUpdateInterval, target: self,
                selector: #selector(ExpGainView.updateProgress), userInfo: nil, repeats: true)
        })
        
        self.expLabel?.text = "+\(String(earnedExp))XP"
    }
    
    func updateProgress() {
        if (progressView == nil) {
            NSLog("call to updateProgress while no myInit")
            return
        }

        var targetProgress = Float(userExp) / Float(nextLvlExp)
        if (targetProgress > 1) {
            targetProgress = 1.0
        }
        
        if (progressView!.progress >= targetProgress) {
            self.progressBarTimer?.invalidate()
            
            if (progressView!.progress == 1) {
                let userLvl = String(currentUserService.getUserLvl() + 1)
                
                dispatch_async(dispatch_get_main_queue()) {
                    usleep(1000 * 500)
                    
                    UIView.animateWithDuration(1,
                        animations: {
                            self.lvlLabel?.text = "LEVEL \(userLvl)"
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
            
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(
                    1,
                    animations: {
                        self.progressView?.setProgress(
                            self.progressView!.progress + progressStep, animated: true
                        )
                    }
                )
            }
        }
    }
}