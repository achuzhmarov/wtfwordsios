//
//  NetworkHelper.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 23/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

//let networkService = NetworkService(baseUrl: "https://127.0.0.1:5000/")
let networkService = NetworkService(baseUrl: "https://wtfchat.wtf:42042/")

class NetworkService: NSObject, NSURLSessionDelegate {
    var baseUrl: String
    //var session = NSURLSession.sharedSession()
    
    private var session: NSURLSession!
    
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
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: self,
            delegateQueue: nil)
    }
    
    /*func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }*/
    
    /*func get(relativeUrl: String, completion:(json: JSON?, error: NSError?) -> Void) {
        let url = baseUrl + relativeUrl
        
        do {
            let opt = try HTTP.GET(url)
            opt.start { response in
                
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    completion(json: nil, error: err)
                    return
                }
                
                print("opt finished: \(response.description)")
                print("data is: \(response.data)")
                //access the response of the data with response.data
            }
        } catch let error as NSError {
            print("got an error creating the request: \(error)")
            completion(json: nil, error: error)
        }
        
        /*let loadDataTask = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
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
        
        loadDataTask.resume()*/
    }
    
    func post(postJSON: JSON?, relativeUrl: String, completion:(json: JSON?, error: NSError?) -> Void) {
        let url = baseUrl + relativeUrl
        
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            var opt: HTTP
            
            if let sendJson = postJSON {
                opt = try HTTP.POST(url, parameters: sendJson.rawDictionary)
            } else {
                opt = try HTTP.POST(url, parameters: nil)
            }
            
            opt.start { response in
                if let error = response.error {
                    print("got an error: \(error)")
                    completion(json: nil, error: error)
                    return
                }
                
                print("response: \(response)")
                
                //let resp = JSON(data: response.data)
                //let resp = Response(JSONDecoder(response.data))
                /*if let err = resp.error {
                    print("got an error: \(err)")
                }*/
                
                /*if let status = resp.status {
                    print("completed: \(status)")
                }*/
            }
        } catch let error as NSError {
            print("got an error creating the request: \(error)")
            completion(json: nil, error: error)
        }
        
        /*let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
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
        
        task.resume()*/
    }*/
    
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
