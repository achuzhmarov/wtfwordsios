import Foundation

class AdColonyAdProvider: NSObject, AdProvider, AdColonyDelegate, AdColonyAdDelegate {
    private let APP_ID = NSBundle.mainBundle().objectForInfoDictionaryKey("AD_COLONY_APP_ID") as! String
    private let ZONE_REWARDED_ID = NSBundle.mainBundle().objectForInfoDictionaryKey("AD_COLONY_REWARD_ZONE") as! String

    private var isAvailable = false

    var delegateFunc: (() -> Void)?

    func initProvider() {
        AdColony.configureWithAppID(APP_ID, zoneIDs: [ZONE_REWARDED_ID], delegate: self, logging: true)
    }

    func hasAd() -> Bool {
        return isAvailable
    }
    
    func showAd(delegateFunc: (() -> Void)) {
        self.delegateFunc = delegateFunc
        AdColony.playVideoAdForZone(ZONE_REWARDED_ID, withDelegate: self, withV4VCPrePopup: false, andV4VCPostPopup: false)
    }
    
    func onAdColonyV4VCReward(success: Bool, currencyName: String, currencyAmount amount: Int32, inZone zoneID: String)
    {
        print("AdColony zone: %@ reward: %@ amount: %i", zoneID, success ? "YES" : "NO", amount)
        
        if success {
            print(amount)
        }
    }

    func onAdColonyAdAvailabilityChange(available: Bool, inZone zoneID: String)
    {
        if zoneID == ZONE_REWARDED_ID {
            isAvailable = available
        }
    }
    
    func onAdColonyAdAttemptFinished(shown: Bool, inZone zoneID: String)
    {
        if shown {
            delegateFunc?()
        }
    }
}