import Foundation

class UserService: Service {
    fileprivate let USER_UPDATE_TIMER_INTERVAL = 10.0

    fileprivate let userNetworkService: UserNetworkService
    fileprivate let iosService: IosService
    fileprivate let talkService: TalkService
    fileprivate let currentUserService: CurrentUserService
    fileprivate let windowService: WindowService

    fileprivate var updateTimer: Foundation.Timer?
    
    fileprivate var freeAdHintsNotAdded = 0

    init(userNetworkService: UserNetworkService, iosService: IosService, talkService: TalkService, currentUserService: CurrentUserService, windowService: WindowService) {
        self.userNetworkService = userNetworkService
        self.iosService = iosService
        self.talkService = talkService
        self.currentUserService = currentUserService
        self.windowService = windowService
    }

    /*func setNewUser(user: User, password: String) {
        currentUserService.setNewUser(user)
        talkService.setTalksByNewUser(user)
        iosService.updateUserCredentials(user.login, password: password)
        
        //timer worked only on main
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTimer?.invalidate()
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(self.USER_UPDATE_TIMER_INTERVAL, target: self,
                selector: #selector(UserService.updateInfo), userInfo: nil, repeats: true)
        })
    }*/
    
    func updateInfo() {
        //send free hints gain in case of errors
        if (freeAdHintsNotAdded != 0) {
            let freeAdHintsToAdd = freeAdHintsNotAdded
            freeAdHintsNotAdded = 0
            
            for _ in 0..<freeAdHintsToAdd {
                addFreeAdHintRequest()
            }
        }
        
        //get new user info
        userNetworkService.getNewInfo(currentUserService.getLastUpdate()) {userInfo, error in
            if let requestError = error {
                print(requestError)
            } else {
                self.updateUserInfo(userInfo)
            }
        }
    }
    
    func updateUserInfo(_ userInfo: User?) {
        if (userInfo == nil) {
            return
        }
        
        currentUserService.updateInfo(userInfo!)
    }
    
    func getNewFriends(_ searchString: String, completion:(_ friends: [FriendInfo]?, _ error: NSError?) -> Void) {
        userNetworkService.getNewFriends(searchString, completion: completion)
    }
    
    func getTopRatings(_ completion:(_ friends: [FriendInfo]?, _ error: NSError?) -> Void) {
        userNetworkService.getTopRatings(completion)
    }
    
    func getFriendsRating(_ completion:(_ friends: [FriendInfo]?, _ error: NSError?) -> Void) {
        userNetworkService.getFriendsRating(completion)
    }
    
    func makeFriends(_ friend: FriendInfo, completion:(_ talk: FriendTalk?, _ error: NSError?) -> Void) {
        currentUserService.addFriend(friend)
        userNetworkService.makeFriends(friend.login, completion: completion)
    }
    
    func updatePassword(_ oldPassword: String, newPassword: String, completion:(_ error: NSError?) -> Void) {
        userNetworkService.updatePassword(oldPassword, newPassword: newPassword, completion: completion)
    }
    
    func updateName(_ name: String, completion:@escaping (_ error: NSError?) -> Void) {
        userNetworkService.updateName(name) { error in
            if (error == nil) {
                self.currentUserService.updateName(name)
            }
            
            completion(error: error)
        }
    }
    
    func updatePushNew(_ pushNew: Bool, completion:@escaping (_ error: NSError?) -> Void) {
        userNetworkService.updatePushNew(pushNew) { error in
            if (error == nil) {
                self.currentUserService.updatePushNew(pushNew)
            }
            
            completion(error: error)
        }
    }
    
    func updatePushDeciphered(_ pushDeciphered: Bool, completion:@escaping (_ error: NSError?) -> Void) {
        userNetworkService.updatePushDeciphered(pushDeciphered) { error in
            if (error == nil) {
                self.currentUserService.updatePushDeciphered(pushDeciphered)
            }
            
            completion(error: error)
        }
    }
    
    func addFreeAdHint() {
        currentUserService.addFreeHint()
        
        addFreeAdHintRequest()
    }
    
    fileprivate func addFreeAdHintRequest() {
        userNetworkService.addFreeAdHint { (userInfo, error) -> Void in
            if let requestError = error {
                self.freeAdHintsNotAdded += 1
                
                NSLog(requestError.localizedDescription)
            } else {
                if (userInfo != nil) {
                    self.updateUserInfo(userInfo)
                }
            }
        }
    }
}
