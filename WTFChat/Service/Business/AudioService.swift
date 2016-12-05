//
//  AudioService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 11/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit
import AVFoundation

enum WtfSound: String {
    case error = "error.wav"
    case lose = "lose.wav"
    case success = "success.wav"
    case warning = "warning.wav"
    case win = "win.wav"

    var fileName: String {
        return self.rawValue
    }

    static var getAll: [WtfSound] {
        return [.error, .lose, .success, .warning, .win]
    }
}

class AudioService: Service {
    private var audio = [WtfSound: AVAudioPlayer]()

    override func initService() {
        for wtfSound in WtfSound.getAll {
            do {
                var soundURL = URL.init(fileURLWithPath: Bundle.main.resourcePath!);
                soundURL.appendPathComponent(wtfSound.fileName)

                let player = try AVAudioPlayer(contentsOf: soundURL)

                player.numberOfLoops = 0
                player.prepareToPlay()

                audio[wtfSound] = player
            } catch {
                assert(false, "Load sound failed")
            }
        }
    }

    func playSound(_ wtfSound: WtfSound) {
        if let player = audio[wtfSound] {
            if player.isPlaying {
                player.currentTime = 0
            } else {
                player.play()
            }
        }
    }
}
