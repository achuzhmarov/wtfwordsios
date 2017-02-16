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

    private let guiDataService: GuiDataService

    init(guiDataService: GuiDataService) {
        self.guiDataService = guiDataService
    }

    override func initService() {
        coexistWithExternalSounds()

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
        if (guiDataService.isSoundOn()) {
            if let player = audio[wtfSound] {
                if player.isPlaying {
                    player.currentTime = 0
                } else {
                    player.play()
                }
            }
        }
    }

    private func coexistWithExternalSounds() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryAmbient, with: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audioSession");
        }
    }
}
