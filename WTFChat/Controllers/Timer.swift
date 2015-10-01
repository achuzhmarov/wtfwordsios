//
//  Timer.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 10/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class Timer {
    var seconds = 0
    
    init() {}
    
    init(seconds: Int) {
        self.seconds = seconds
    }
    
    func tick() -> Bool {
        if (self.seconds > 0) {
            self.seconds -= 1
        }
        
        return isFinished()
    }
    
    func isFinished() -> Bool {
        if (self.seconds <= 0) {
            return true
        } else {
            return false
        }
    }
    
    func getMinutes() -> Int {
        return seconds / 60
    }
    
    func getSeconds() -> Int {
        return seconds % 60
    }
    
    func getTimeString() -> String {
        return String(format: "%02d", getMinutes()) + ":" + String(format: "%02d", getSeconds())
    }
}
