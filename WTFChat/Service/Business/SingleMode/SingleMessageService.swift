import Foundation

class SingleMessageService: Service {
    private let textGeneratorService: TextGeneratorService
    private let messageCipherService: MessageCipherService

    init(textGeneratorService: TextGeneratorService,
         messageCipherService: MessageCipherService) {

        self.messageCipherService = messageCipherService
        self.textGeneratorService = textGeneratorService
    }

    func getTextForLevel(level: Level) -> String {
        return textGeneratorService.getTextForLevel(level)
    }

    func getMessageForLevel(level: Level, difficulty: CipherDifficulty, text: String) -> SingleMessage {
        let message = messageCipherService.createMessage(
            text,
            cipherType: level.category.cipherType,
            cipherDifficulty: difficulty
        )

        let singleMessage = SingleMessage(message: message)
        singleMessage.level = level

        return singleMessage
    }

    /*func updateMessage(singleMessage: SingleMessage) {
        coreSingleMessageService.updateMessage(singleMessage)
    }*/
}
