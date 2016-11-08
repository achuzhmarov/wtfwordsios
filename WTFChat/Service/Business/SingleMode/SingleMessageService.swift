import Foundation

class SingleMessageService: Service {
    fileprivate let textGeneratorService: TextCategoryService
    fileprivate let messageCipherService: MessageCipherService

    init(textGeneratorService: TextCategoryService,
         messageCipherService: MessageCipherService) {

        self.messageCipherService = messageCipherService
        self.textGeneratorService = textGeneratorService
    }

    func hasTextCategoryForLevel(_ level: Level) -> Bool {
        let text = textGeneratorService.getTextCategoryForLevel(level)
        return text != nil
    }

    func getTextCategoryForLevel(_ level: Level) -> TextCategory! {
        return textGeneratorService.getTextCategoryForLevel(level)!
    }

    func getMessageForLevel(_ level: Level, difficulty: CipherDifficulty, text: String) -> SingleMessage {
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
