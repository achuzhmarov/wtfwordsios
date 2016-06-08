import Foundation

class SingleTalkService: Service {
    private let coreSingleTalkService: CoreSingleTalkService
    private let cipherService: CipherService

    private var singleTalks = [SingleTalk]()

    init(coreSingleTalkService: CoreSingleTalkService, cipherService: CipherService) {
        self.coreSingleTalkService = coreSingleTalkService
        self.cipherService = cipherService
    }

    override func initService() {
        self.singleTalks = coreSingleTalkService.getAll()

        for cipherType in CipherType.getAll() {
            for cipherDifficulty in CipherDifficulty.getAll() {
                createSingleTalkIfNotExists(cipherType, cipherDifficulty: cipherDifficulty)
            }
        }

        for singleTalk in singleTalks {
            addSettingsToSingleTalk(singleTalk)
        }
    }

    private func createSingleTalkIfNotExists(cipherType: CipherType, cipherDifficulty: CipherDifficulty) {
        for singleTalk in singleTalks {
            if (singleTalk.cipherType == cipherType && singleTalk.cipherDifficulty == cipherDifficulty) {
                return
            }
        }

        createSingleTalk(cipherType, cipherDifficulty: cipherDifficulty)
    }

    private func createSingleTalk(cipherType: CipherType, cipherDifficulty: CipherDifficulty) {
        let singleTalk = SingleTalk(cipherType: cipherType, cipherDifficulty:cipherDifficulty)

        coreSingleTalkService.createSingleTalk(singleTalk)

        self.singleTalks.append(singleTalk)
    }

    private func addSettingsToSingleTalk(singleTalk: SingleTalk) {
        let settings = cipherService.getCipherSettings(singleTalk.cipherType, difficulty: singleTalk.cipherDifficulty)
        singleTalk.cipherSettings = settings
    }

    func getSingleTalk(cipherType: CipherType, cipherDifficulty: CipherDifficulty) -> SingleTalk? {
        for singleTalk in singleTalks {
            if (singleTalk.cipherType == cipherType && singleTalk.cipherDifficulty == cipherDifficulty) {
                return singleTalk
            }
        }

        return nil
    }
}
