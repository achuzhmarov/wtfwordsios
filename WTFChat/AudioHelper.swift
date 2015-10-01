//
//  AudioHelper.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 11/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit
import AVFoundation

var audioHelper = AudioHelper()

class AudioHelper {
    
    var audioPlayer:AVAudioPlayer!
    let defaultExt = "wav"
    
    func playSound(fileName: String) {
        playSound(fileName, ext: defaultExt)
    }
    
    func playSound(fileName: String, ext: String) {
        
        let audioFilePath = NSBundle.mainBundle().pathForResource(fileName, ofType: ext)
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            
            audioPlayer = try? AVAudioPlayer(contentsOfURL: audioFileUrl)
            audioPlayer.play()
            
        } else {
            print("audio file " + fileName + "." + ext + " is not found")
        }
    }
}