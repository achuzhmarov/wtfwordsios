import Foundation

class CharBoostAdProvider: NSObject, AdProvider, ChartboostDelegate {
    private let APP_ID = NSBundle.mainBundle().objectForInfoDictionaryKey("CHARTBOOST_APP_ID") as! String
    private let APP_SIGNATURE = NSBundle.mainBundle().objectForInfoDictionaryKey("CHARTBOOST_APP_SIGNATURE") as! String

    var delegateFunc: (() -> Void)?

    func initProvider() {
        Chartboost.startWithAppId(APP_ID, appSignature: APP_SIGNATURE, delegate: self)
        Chartboost.cacheRewardedVideo(CBLocationMainMenu)
    }

    func hasAd() -> Bool {
        if (Chartboost.hasRewardedVideo(CBLocationMainMenu)) {
            return true
        } else {
            Chartboost.cacheRewardedVideo(CBLocationMainMenu)
            return false
        }
    }
    
    func showAd(delegateFunc: (() -> Void)) {
        self.delegateFunc = delegateFunc
        Chartboost.showRewardedVideo(CBLocationMainMenu)
    }

    func didCompleteRewardedVideo(location: CBLocation, withReward reward: Int?) {
        delegateFunc?()
    }
}