import Foundation

protocol AdProvider {
    func initProvider()
    func hasAd() -> Bool
    func showAd(_ delegateFunc: @escaping (() -> Void))
}

class AdService: Service {
    fileprivate let adProviders: [AdProvider] = [AdColonyAdProvider()]

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

    func showAd(_ delegateFunc: @escaping (() -> Void)) {
        for adProvider in adProviders {
            if adProvider.hasAd() {
                adProvider.showAd(delegateFunc)
                return
            }
        }
    }
}
