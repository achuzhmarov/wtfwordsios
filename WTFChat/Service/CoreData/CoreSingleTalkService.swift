import Foundation

class CoreSingleTalkService: Service {
    private let CORE_SINGLE_TALK_CLASS_NAME = "CoreSingleTalk"

    private let coreDataService: CoreDataService

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func createSingleTalk(singleTalk: SingleTalk) {
        let newCoreSingleTalk = coreDataService.createObject(CORE_SINGLE_TALK_CLASS_NAME) as! CoreSingleTalk
        singleTalk.setCoreSingleTalk(newCoreSingleTalk)
        singleTalk.updateCoreSingleTalk()
        coreDataService.saveContext()
    }

    func updateSingleTalk(singleTalk: SingleTalk) {
        singleTalk.updateCoreSingleTalk()
        coreDataService.saveContext()
    }

    func getAll() -> [SingleTalk] {
        let fetchRequest = coreDataService.createFetch(CORE_SINGLE_TALK_CLASS_NAME)
        let results = coreDataService.executeFetch(fetchRequest)

        var domainTalks = [SingleTalk]()

        for item in results {
            if let coreSingleTalk = item as? CoreSingleTalk {
                if let domainTalk = coreSingleTalk.getSingleTalk() {
                    domainTalks.append(domainTalk)
                }
            }
        }

        return domainTalks
    }
}
