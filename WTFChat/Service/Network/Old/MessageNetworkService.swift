import Foundation
import SwiftyJSON

class MessageNetworkService: Service {
    fileprivate let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func markTalkAsReaded(_ talk: FriendTalk, completion:@escaping (_ error: NSError?) -> Void) {
        networkService.post(nil, relativeUrl: "messages/read/\(talk.id)") { (json, error) -> Void in
            completion(error)
        }
    }
    
    func getMessagesByTalk(_ talk: FriendTalk, completion: @escaping (_ messages: [RemoteMessage]?, _ error: NSError?) -> Void) {
        networkService.get("messages/\(talk.id)") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                do {
                    let messages = try JsonRemoteMessageParser.arrayFromJson(json!)
                    completion(messages, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
                
            }
        }
    }
    
    func getUnreadMessagesByTalk(
        _ talk: FriendTalk,
        lastUpdate: Date,
        completion:@escaping (_ messages: [RemoteMessage]?, _ error: NSError?) -> Void)
    {
        let lastUpdateData = [
            "last_update": Date.parseStringJSONFromDate(lastUpdate)!
        ]
        
        let postJSON = JSON(lastUpdateData)
        
        networkService.post(postJSON, relativeUrl: "messages/new/\(talk.id)") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let messagesJson = json {
                    do {
                        let messages = try JsonRemoteMessageParser.arrayFromJson(messagesJson)
                        completion(messages, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func getEarlierMessagesByTalk(
        _ talk: FriendTalk,
        skip: Int,
        completion:@escaping (_ messages: [RemoteMessage]?, _ error: NSError?) -> Void)
    {
        networkService.get("messages/earlier/\(talk.id)/\(String(skip))") { (json, error) -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let messagesJson = json {
                    do {
                        let messages = try JsonRemoteMessageParser.arrayFromJson(messagesJson)
                        completion(messages, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func saveMessage(_ message: RemoteMessage, completion:@escaping (_ message: RemoteMessage?, _ error: NSError?) -> Void) {
        let postJSON = JsonRemoteMessageParser.newFromMessage(message)
        
        networkService.post(postJSON, relativeUrl: "messages/add") {json, error -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let messageJson = json {
                    do {
                        let message = try JsonRemoteMessageParser.fromJson(messageJson)
                        completion(message, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func decipherMessage(_ message: RemoteMessage, completion:@escaping (_ message: RemoteMessage?, _ error: NSError?) -> Void) {
        let postJSON = JsonRemoteMessageParser.decipherFromMessage(message)
        
        networkService.post(postJSON, relativeUrl: "messages/decipher") {json, error -> Void in
            if let requestError = error {
                completion(nil, requestError)
            } else {
                if let messageJson = json {
                    do {
                        let message = try JsonRemoteMessageParser.fromJson(messageJson)
                        completion(message, nil)
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
}
