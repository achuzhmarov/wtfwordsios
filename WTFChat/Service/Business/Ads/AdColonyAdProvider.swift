import Foundation

class AdColonyAdProvider: NSObject, AdProvider, AdColonyDelegate, AdColonyAdDelegate {
    fileprivate let APP_ID = Bundle.main.object(forInfoDictionaryKey: "AD_COLONY_APP_ID") as! String
    fileprivate let ZONE_REWARDED_ID = Bundle.main.object(forInfoDictionaryKey: "AD_COLONY_REWARD_ZONE") as! String

    fileprivate var isAvailable = false

    var delegateFunc: (() -> Void)?

    func initProvider() {
        AdColony.configure(withAppID: APP_ID, zoneIDs: [ZONE_REWARDED_ID], delegate: self, logging: true)
    }

    func hasAd() -> Bool {
        return isAvailable
    }
    
    func showAd(_ delegateFunc: @escaping (() -> Void)) {
        self.delegateFunc = delegateFunc
        AdColony.playVideoAd(forZone: ZONE_REWARDED_ID, with: self, withV4VCPrePopup: false, andV4VCPostPopup: false)
    }
    
    func onAdColonyV4VCReward(_ success: Bool, currencyName: String, currencyAmount amount: Int32, inZone zoneID: String)
    {
        print("AdColony zone: %@ reward: %@ amount: %i", zoneID, success ? "YES" : "NO", amount)
        
        if success {
            print(amount)
        }
    }

    func onAdColonyAdAvailabilityChange(_ available: Bool, inZone zoneID: String)
    {
        if zoneID == ZONE_REWARDED_ID {
            isAvailable = available
        }
    }
    
    func onAdColonyAdAttemptFinished(_ shown: Bool, inZone zoneID: String)
    {
        if shown {
            delegateFunc?()
        }
    }
}
