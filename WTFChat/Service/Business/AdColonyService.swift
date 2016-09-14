import Foundation

class AdColonyService: Service, AdColonyDelegate, AdColonyAdDelegate {
    private let APP_ID = NSBundle.mainBundle().objectForInfoDictionaryKey("AD_COLONY_APP_ID") as! String
    private let ZONE_INTER_ID = NSBundle.mainBundle().objectForInfoDictionaryKey("AD_COLONY_INTER_ZONE") as! String
    private let ZONE_REWARDED_ID = NSBundle.mainBundle().objectForInfoDictionaryKey("AD_COLONY_REWARD_ZONE") as! String

    private var isInterAvailable = false
    private var isRewardedAvailable = false

    var delegateFunc: (() -> Void)?

    override func initService() {
        //Configure AdColony once on app launch
        AdColony.configureWithAppID(APP_ID, zoneIDs: [ZONE_INTER_ID, ZONE_REWARDED_ID], delegate: self, logging: true)
    }

    func hasAd() -> Bool {
        return hasRewardedAd() || hasInterAd()
    }
    
    func showAd(delegateFunc: (() -> Void)? = nil) {
        if hasRewardedAd() {
            showRewardedVideoAd(delegateFunc)
        } else if hasInterAd() {
            showInterstitialAd(delegateFunc)
        }
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
        if zoneID == ZONE_INTER_ID {
            isInterAvailable = available
        }
        
        if zoneID == ZONE_REWARDED_ID {
            isRewardedAvailable = available
        }
    }
    
    func onAdColonyAdAttemptFinished(shown: Bool, inZone zoneID: String)
    {
        if shown {
            delegateFunc?()
        }
    }
    
    private func showInterstitialAd(delegateFunc: (() -> Void)? = nil) {
        self.delegateFunc = delegateFunc
        
        AdColony.playVideoAdForZone(ZONE_INTER_ID, withDelegate: self)
    }
    
    private func showRewardedVideoAd(delegateFunc: (() -> Void)? = nil) {
        self.delegateFunc = delegateFunc
        
        AdColony.playVideoAdForZone(ZONE_REWARDED_ID, withDelegate: self, withV4VCPrePopup: false, andV4VCPostPopup: false)
    }
    
    private func hasInterAd() -> Bool {
        return isInterAvailable
    }
    
    private func hasRewardedAd() -> Bool {
        return isRewardedAvailable
    }
}