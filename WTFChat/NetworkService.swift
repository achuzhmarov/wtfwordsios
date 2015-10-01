//
//  NetworkHelper.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 23/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let networkService = NetworkService(baseUrl: "http://localhost:8080/")

class NetworkService {
    var baseUrl: String
    var session = NSURLSession.sharedSession()
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
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
