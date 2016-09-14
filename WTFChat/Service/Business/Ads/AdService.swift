import Foundation

protocol AdProvider {
    func initProvider()
    func hasAd() -> Bool
    func showAd(delegateFunc: (() -> Void))
}

class AdService: Service {
    private let adProviders: [AdProvider] = [CharBoostAdProvider()]
    //private let adProviders: [AdProvider] = [CharBoostAdProvider(), AdColonyAdProvider()]

    override func initServiceOnMain() {
        for adProvider in adProviders {
            adProvider.initProvider()
        }
    }

    func hasAd() -> Bool {
        for adProvider in adProviders {
            if adProvider.hasAd() {
                return true
            }
        }

        return false
    }

    func showAd(delegateFunc: (() -> Void)) {
        for adProvider in adProviders {
            if adProvider.hasAd() {
                adProvider.showAd(delegateFunc)
                return
            }
        }
    }
}
