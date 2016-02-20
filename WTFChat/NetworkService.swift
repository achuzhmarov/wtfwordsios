//
//  NetworkHelper.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 23/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

//let networkService = NetworkService(baseUrl: "https://127.0.0.1:5000/")
let networkService = NetworkService(baseUrl: "https://dev.wtfchat.wtf:42043/")

class NetworkService: NSObject, NSURLSessionDelegate {
    var baseUrl: String
    private var session: NSURLSession!
    
    let REQUEST_REPEAT_COUNT = 3
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
        super.init()
        
        clearSession()
    }
    
    func updateSessionConfiguration(config: NSURLSessionConfiguration) {
        session = NSURLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil)
    }
    
    func clearSession() {
        session = NSURLSession(
            configuration: getDefaultConfiguration(),
            delegate: self,
            delegateQueue: nil)
    }
    
    func getDefaultConfiguration() -> NSURLSessionConfiguration {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForResource = 1
        return config
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }
    
    func post(postJSON: JSON?, relativeUrl: String, completion:(json: JSON?, error: NSError?) -> Void) {
        let url = NSURL(string: baseUrl + relativeUrl)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        if let sendJson = postJSON {
            do {
                request.HTTPBody = try sendJson.rawData()
            }
            catch let error as NSError {
                completion(json: nil, error: error)
            }
        }
            
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        sendPostRequestWithRepeats(request, repeats: REQUEST_REPEAT_COUNT, completion: completion)
    }
    
    private func sendPostRequestWithRepeats(request: NSMutableURLRequest, repeats: Int, completion:(json: JSON?, error: NSError?) -> Void) {
        
        sendPostRequest(request) { (json, error) -> Void in
            if error != nil && repeats > 0 {
                //in case of a error, try again
                self.sendPostRequestWithRepeats(request, repeats: repeats - 1, completion: completion)
            } else {
                completion(json: json, error: error)
            }
        }
    }
    
    private func sendPostRequest(request: NSMutableURLRequest, completion:(json: JSON?, error: NSError?) -> Void) {
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if let responseError = error {
                completion(json: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(code:httpResponse.statusCode, message: "HTTP status code has unexpected value.")
                    
                    completion(json: nil, error: statusError)
                } else if data!.length > 0 {
                    completion(json: JSON(data: data!), error: nil)
                } else {
                    completion(json: nil, error: nil)
                }
            }
        })
        
        task.resume()
    }
    
    func get(relativeUrl: String, completion:(json: JSON?, error: NSError?) -> Void) {
        let url = NSURL(string: baseUrl + relativeUrl)!
        
        sendGetRequestWithRepeats(url, repeats: REQUEST_REPEAT_COUNT, completion: completion)
    }
    
    private func sendGetRequestWithRepeats(url: NSURL, repeats: Int, completion:(json: JSON?, error: NSError?) -> Void) {
        
        sendGetRequest(url) { (json, error) -> Void in
            if error != nil && repeats > 0 {
                //in case of a error, try again
                self.sendGetRequestWithRepeats(url, repeats: repeats - 1, completion: completion)
            } else {
                completion(json: json, error: error)
            }
        }
    }
    
    private func sendGetRequest(url: NSURL, completion:(json: JSON?, error: NSError?) -> Void) {
        let loadDataTask = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let responseError = error {
                completion(json: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(code:httpResponse.statusCode, message : "HTTP status code has unexpected value.")
                    
                    completion(json: nil, error: statusError)
                } else if data!.length > 0 {
                    completion(json: JSON(data: data!), error: nil)
                } else {
                    completion(json: nil, error: nil)
                }
            }
        }
        
        loadDataTask.resume()
    }
}
