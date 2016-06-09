import Foundation

enum StarStatus : Int {
    case NoChange = 0
    case EarnStar
    case Mastered
}

class SingleModeService: Service {
    private let singleMessageService: SingleMessageService
    private let singleTalkService: SingleTalkService
    private let expService: ExpService
    private let currentUserService: CurrentUserService

    init(singleMessageService: SingleMessageService,
         singleTalkService: SingleTalkService,
         expService: ExpService,
         currentUserService: CurrentUserService)
    {
        self.singleMessageService = singleMessageService
        self.singleTalkService = singleTalkService
        self.expService = expService
        self.currentUserService = currentUserService
    }

    func finishDecipher(singleMessage: SingleMessage) {
        singleMessage.exp = expService.calculateExpForMessage(singleMessage)
        singleMessageService.updateMessage(singleMessage)

        if (singleMessage.getMessageStatus() == .Success) {
            let talk = singleMessage.singleTalk
            talk.wins += 1

            singleTalkService.updateSingleTalk(talk)
        }

        currentUserService.earnSingleExp(singleMessage.exp)
    }

    func getStarStatus(singleMessage: SingleMessage) -> StarStatus {
        if (singleMessage.getMessageStatus() == .Success) {
            let talk = singleMessage.singleTalk

            if (talk.wins < talk.cipherSettings!.maxStars) {
                return .EarnStar
            } else if (talk.wins == talk.cipherSettings!.maxStars) {
                return .Mastered
            }
        }

        return .NoChange
    }
}
