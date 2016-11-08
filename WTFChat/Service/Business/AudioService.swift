//
//  AudioService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 11/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit
import AVFoundation

class AudioService: Service {
    
    var audioPlayer:AVAudioPlayer!
    let defaultExt = "wav"
    
    func playSound(_ fileName: String) {
        playSound(fileName, ext: defaultExt)
    }
    
    func playSound(_ fileName: String, ext: String) {
        
        let audioFilePath = Bundle.main.path(forResource: fileName, ofType: ext)
        
        if audioFilePath != nil {
            
            let audioFileUrl = URL(fileURLWithPath: audioFilePath!)
            
            audioPlayer = try? AVAudioPlayer(contentsOf: audioFileUrl)
            audioPlayer.play()
            
        } else {
            print("audio file \(fileName).\(ext) is not found")
        }
    }
}
