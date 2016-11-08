import Foundation
import SwiftyJSON

class AuthNetworkService: Service {
    fileprivate let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func login(_ login: String, password: String, completion: @escaping (_ user: User?, _ error: NSError?) -> Void) {
        self.authorize(login, password: password) { error -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                self.getUserInfo() { user, error -> Void in
                    if let requestError = error {
                        completion(nil, requestError)
                    } else {
                        completion(user, nil)
                    }
                }
            }
        }
    }
    
    func logout(_ deviceToken: NSString?, completion:@escaping (_ error: NSError?) -> Void) {
        var postJSON: JSON? = nil
        
        if deviceToken != nil {
            let userData = [
                "device_token": deviceToken!
            ]
            
            postJSON = JSON(userData)
        }
        
        networkService.post(postJSON, relativeUrl: "logout") { (json, error) -> Void in
            completion(error)
        }
    }
    
    func register(_ login: String, password: String, email: String, completion:@escaping (_ error: NSError?) -> Void) {
        let userData = [
            "login": login,
            "password": password,
            "email": email
        ]
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "user/add") {json, error -> Void in
            if let requestError = error {
                completion(requestError)
            } else {
                completion(nil)
            }
        }
    }
    
    func restorePassword(_ login: String, completion:@escaping (_ error: NSError?) -> Void) {
        var userData: [String: NSString]
        
        userData = [
            "login": login as NSString,
        ]
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "restore") {json, error -> Void in
            completion(error)
        }
    }
    
    func changePassword(_ login: String, password: String, code: String, completion:@escaping (_ error: NSError?) -> Void) {
        let userData = [
            "login": login,
            "password": password,
            "code": code
        ]
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "change_password") {json, error -> Void in
            if let requestError = error {
                completion(requestError)
            } else {
                completion(nil)
            }
        }
    }
    
    fileprivate func authorize(_ login: String, password: String, completion:@escaping (_ error: NSError?) -> Void) {
        var userData: [String: NSString]
        
        if let deviceToken = DEVICE_TOKEN {
            userData = [
                "login": login as NSString,
                "password": password as NSString,
                "device_token": deviceToken
            ]
        } else {
            userData = [
                "login": login as NSString,
                "password": password as NSString
            ]
        }
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "login") {json, error -> Void in
            if let requestError = error {
                completion(requestError)
            } else if let token = json!["token"].string {
                let config = self.networkService.getDefaultConfiguration()
                let authString = "Bearer \(token)"
                config.httpAdditionalHeaders = ["Authorization" : authString]
                
                self.networkService.updateSessionConfiguration(config)
                
                completion(nil)
            } else {
                completion(json!["token"].error)
            }
        }
    }
    
    fileprivate func getUserInfo(_ completion:@escaping (_ user: User?, _ error: NSError?) -> Void) {
        networkService.get("user") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else if let userJson = json {
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
