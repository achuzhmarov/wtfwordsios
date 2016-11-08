import Foundation
import SwiftyJSON

class UserNetworkService: Service {
    let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getNewInfo(_ lastUpdate: Date, completion:@escaping (_ userInfo: User?, _ error: NSError?) -> Void) {
        let lastUpdateData = [
            "last_update": Date.parseStringJSONFromDate(lastUpdate)!
        ]
        
        let postJSON = JSON(lastUpdateData)
        
        networkService.post(postJSON, relativeUrl: "user/new_info") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let userJson = json {
                    do {
                        let user = try JsonUserParser.fromJson(userJson)
                        completion(user, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func getNewFriends(_ searchString: String, completion:@escaping (_ friends: [FriendInfo]?, _ error: NSError?) -> Void) {
        var url = "user/friends"
        
        if (searchString != "") {
            url = "\(url)/\(searchString.escapeForUrl()!)"
        }
        
        networkService.get(url) { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let friendsJson = json {
                    do {
                        let friends = try JsonUserParser.friendsFromJson(friendsJson)
                        completion(friends, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func getTopRatings(_ completion:@escaping (_ friends: [FriendInfo]?, _ error: NSError?) -> Void) {
        networkService.get("user/top") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let friendsJson = json {
                    do {
                        let friends = try JsonUserParser.friendsFromJson(friendsJson)
                        completion(friends, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func getFriendsRating(_ completion:@escaping (_ friends: [FriendInfo]?, _ error: NSError?) -> Void) {
        networkService.get("user/friendsRating") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let friendsJson = json {
                    do {
                        let friends = try JsonUserParser.friendsFromJson(friendsJson)
                        completion(friends, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func makeFriends(_ friendLogin: String, completion:@escaping (_ talk: FriendTalk?, _ error: NSError?) -> Void) {
        networkService.post(nil, relativeUrl:"user/friend/\(friendLogin.escapeForUrl()!)") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let talkJson = json {
                    do {
                        let talk = try JsonTalkParser.fromJson(talkJson)
                        completion(talk, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func updatePassword(_ oldPassword: String, newPassword: String, completion:@escaping (_ error: NSError?) -> Void) {
        let requestData = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/password") { (json, error) -> Void in
            if let requestError = error {
                completion(requestError)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateName(_ name: String, completion:@escaping (_ error: NSError?) -> Void) {
        let requestData = [
            "name": name
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/name") { (json, error) -> Void in
            if let requestError = error {
                completion(requestError)
            } else {
                completion(nil)
            }
        }
    }
    
    func updatePushNew(_ pushNew: Bool, completion:@escaping (_ error: NSError?) -> Void) {
        let requestData = [
            "push_new": pushNew
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/push_new") { (json, error) -> Void in
            if let requestError = error {
                completion(requestError)
            } else {
                completion(nil)
            }
        }
    }
    
    func updatePushDeciphered(_ pushDeciphered: Bool, completion:@escaping (_ error: NSError?) -> Void) {
        let requestData = [
            "push_deciphered": pushDeciphered
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/push_deciphered") { (json, error) -> Void in
            if let requestError = error {
                completion(requestError)
            } else {
                completion(nil)
            }
        }
    }
    
    func addFreeAdHint(_ completion:@escaping (_ userInfo: User?, _ error: NSError?) -> Void) {
        let url = "user/add_hint"
        
        networkService.post(nil, relativeUrl: url) { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let userJson = json {
                    do {
                        let user = try JsonUserParser.fromJson(userJson)
                        completion(user, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                }
            }
        }
    }
}
