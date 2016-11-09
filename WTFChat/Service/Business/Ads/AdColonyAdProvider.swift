import Foundation

class AdColonyAdProvider: NSObject, AdProvider {
    fileprivate let APP_ID = Bundle.main.object(forInfoDictionaryKey: "AD_COLONY_APP_ID") as! String
    fileprivate let ZONE_REWARDED_ID = Bundle.main.object(forInfoDictionaryKey: "AD_COLONY_REWARD_ZONE") as! String

    fileprivate var isAvailable = false

    var delegateFunc: (() -> Void)?

    private var ad: AdColonyInterstitial?
    
    func initProvider() {
        //Initialize AdColony on initial launch
        AdColony.configure(withAppID: APP_ID, zoneIDs: [ZONE_REWARDED_ID], options: nil,
                completion: { (zones) in
                //Set the zone's reward handler
                let zone = zones.first
                zone?.setReward({(success, name, amount) in
                    if (success) {
                        self.delegateFunc?()
                    }
                })
                            
                //If the application has been inactive for a while, our ad might have expired so let's add a check for a nil ad object
                NotificationCenter.default.addObserver(self, selector: #selector(AdColonyAdProvider.onBecameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
                            
                //AdColony has finished configuring, so let's request an interstitial ad
                self.requestInterstitial()
            }
        )
        
        //AdColony.configure(withAppID: APP_ID, zoneIDs: [ZONE_REWARDED_ID], delegate: self, logging: true)
    }

    func hasAd() -> Bool {
        return isAvailable
    }
    
    func showAd(_ delegateFunc: @escaping (() -> Void)) {
        self.delegateFunc = delegateFunc
        
        if let ad = self.ad {
            if (!ad.expired) {
                let rootViewController: UIViewController = UIApplication.shared.windows.last!.rootViewController!

                if let childController = rootViewController.presentedViewController {
                    print(childController)
                    ad.show(withPresenting: childController)
                } else {
                    print(rootViewController)
                    ad.show(withPresenting: rootViewController)
                }
            }
        }
    }
    
    private func requestInterstitial()
    {
        //Request an interstitial ad from AdColony
        AdColony.requestInterstitial(inZone: ZONE_REWARDED_ID, options:nil,
            //Handler for successful ad requests
            success:{(newAd) in
                
                //Once the ad has finished, set the loading state and request a new interstitial
                newAd.setClose({
                    self.isAvailable = false
                    self.requestInterstitial()
                })
                
                //Interstitials can expire, so we need to handle that event also
                newAd.setExpire( {
                    self.ad = nil
                    self.isAvailable = false
                    self.requestInterstitial()
                })
                
                //Store a reference to the returned interstitial object
                self.ad = newAd
                self.isAvailable = true
        },
            
            //Handler for failed ad requests
            failure:{(error) in
                NSLog("SAMPLE_APP: Request failed with error: " + error.localizedDescription + " and suggestion: " + error.localizedRecoverySuggestion!)
            }
        )
    }
    
    func onBecameActive()
    {
        //If our ad has expired, request a new interstitial
        if (self.ad == nil) {
            self.requestInterstitial()
        }
    }
}
