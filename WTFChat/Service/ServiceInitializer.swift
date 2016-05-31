//
// Created by Artem Chuzhmarov on 30/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let serviceLocator = ServiceLocator()

class ServiceInitializer {
    //private static let BASE_URL = "https://127.0.0.1:5000/"
    private static let BASE_URL = "https://dev.wtfchat.wtf:42043/"

    static func initServices() {
        let currentUserService = CurrentUserService()

        let networkService = NetworkService(baseUrl: BASE_URL)
        let authNetworkService = AuthNetworkService(networkService: networkService)
        let messageNetworkService = MessageNetworkService(networkService: networkService)
        let userNetworkService = UserNetworkService(networkService: networkService)
        let talkNetworkService = TalkNetworkService(networkService: networkService)
        let inAppNetworkService = InAppNetworkService(networkService: networkService)
        let iosNetworkService = IosNetworkService(networkService: networkService)

        let iosService = IosService(iosNetworkService: iosNetworkService)

        let coreDataService = CoreDataService()
        let coreMessageService = CoreMessageService(coreDataService: coreDataService)

        //TODO - AWFUL DEPENDENCY
        let talkService = TalkService(talkNetworkService: talkNetworkService, iosService: iosService, currentUserService: currentUserService, coreMessageService: coreMessageService)
        let messageService = MessageService(messageNetworkService: messageNetworkService, talkService: talkService, coreMessageService: coreMessageService)
        talkService.messageService = messageService

        let windowService = WindowService(talkService: talkService, currentUserService: currentUserService)

        let userService = UserService(userNetworkService: userNetworkService, iosService: iosService, talkService: talkService, currentUserService: currentUserService, windowService: windowService)

        let inAppHelper = InAppHelper(inAppNetworkService: inAppNetworkService, currentUserService: currentUserService, userService: userService, productIdentifiers: IAPProducts.ALL)

        let cipherService = CipherService(currentUserService: currentUserService)

        //network
        serviceLocator.add(
            InAppService(inAppHelper: inAppHelper, currentUserService: currentUserService, cipherService: cipherService),
            iosService,
            userService,
            messageService,
            talkService,
            AuthService(authNetworkService: authNetworkService, iosService: iosService, userService: userService)
        )

        //other
        serviceLocator.add(
            cipherService,
            LvlService(currentUserService: currentUserService),
            MessageCipherService(currentUserService: currentUserService),
            windowService,
            NotificationService(windowService: windowService, messageService: messageService, talkService: talkService)
        )

        //without dependencies
        serviceLocator.add(
            currentUserService,
            AdColonyService(),
            AvatarService(),
            TimeService(),
            AudioService(),
            coreMessageService
        )
    }
}
