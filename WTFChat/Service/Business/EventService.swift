import Foundation

enum WTFEvent {
    case hint = 0, letters, solve, shake
}

class EventService {
    private let guiDataService: GuiDataService

    init(guiDataService: GuiDataService) {
        self.guiDataService = guiDataService
    }

    public func eventAwaiting() -> WTFEvent? {
        return nil
    }

    public func showEvent(_ event: WTFEvent) {

    }
}
