import Foundation
import SwiftyJSON

class NetworkService: Service, URLSessionDelegate {
    fileprivate var baseUrl: String
    fileprivate var session: Foundation.URLSession!

    fileprivate let REQUEST_REPEAT_COUNT = 3
    fileprivate let REQUEST_TIMEOUT_SECONDS = TimeInterval(30)
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
        super.init()
        
        clearSession()
    }
    
    func updateSessionConfiguration(_ config: URLSessionConfiguration) {
        session = Foundation.URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil)
    }
    
    func clearSession() {
        session = Foundation.URLSession(
            configuration: getDefaultConfiguration(),
            delegate: self,
            delegateQueue: nil)
    }
    
    func getDefaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = REQUEST_TIMEOUT_SECONDS
        return config
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
        }
    }
    
    func post(_ postJSON: JSON?, relativeUrl: String, completion:(_ json: JSON?, _ error: NSError?) -> Void) {
        let url = URL(string: baseUrl + relativeUrl)!
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        if let sendJson = postJSON {
            do {
                request.httpBody = try sendJson.rawData()
            }
            catch let error as NSError {
                completion(json: nil, error: error)
            }
        }
            
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        sendPostRequestWithRepeats(request, repeats: REQUEST_REPEAT_COUNT, completion: completion)
    }
    
    fileprivate func sendPostRequestWithRepeats(_ request: NSMutableURLRequest, repeats: Int, completion:(_ json: JSON?, _ error: NSError?) -> Void) {
        
        sendPostRequest(request) { (json, error) -> Void in
            if error != nil && repeats > 0 {
                //in case of a error, try again
                self.sendPostRequestWithRepeats(request, repeats: repeats - 1, completion: completion)
            } else {
                completion(json: json, error: error)
            }
        }
    }
    
    fileprivate func sendPostRequest(_ request: NSMutableURLRequest, completion:(_ json: JSON?, _ error: NSError?) -> Void) {
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            if let responseError = error {
                completion(json: nil, error: responseError)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(code:httpResponse.statusCode, message: "HTTP status code has unexpected value.")
                    
                    completion(json: nil, error: statusError)
                } else if data!.count > 0 {
                    completion(json: JSON(data: data!), error: nil)
                } else {
                    completion(json: nil, error: nil)
                }
            }
        })
        
        task.resume()
    }
    
    func get(_ relativeUrl: String, completion:(_ json: JSON?, _ error: NSError?) -> Void) {
        let url = URL(string: baseUrl + relativeUrl)!
        
        sendGetRequestWithRepeats(url, repeats: REQUEST_REPEAT_COUNT, completion: completion)
    }
    
    fileprivate func sendGetRequestWithRepeats(_ url: URL, repeats: Int, completion:(_ json: JSON?, _ error: NSError?) -> Void) {
        
        sendGetRequest(url) { (json, error) -> Void in
            if error != nil && repeats > 0 {
                //in case of a error, try again
                self.sendGetRequestWithRepeats(url, repeats: repeats - 1, completion: completion)
            } else {
                completion(json: json, error: error)
            }
        }
    }
    
    fileprivate func sendGetRequest(_ url: URL, completion:(_ json: JSON?, _ error: NSError?) -> Void) {
        let loadDataTask = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
            
            if let responseError = error {
                completion(json: nil, error: responseError)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(code:httpResponse.statusCode, message : "HTTP status code has unexpected value.")
                    
                    completion(json: nil, error: statusError)
                } else if data!.count > 0 {
                    completion(json: JSON(data: data!), error: nil)
                } else {
                    completion(json: nil, error: nil)
                }
            }
        } as! (Data?, URLResponse?, Error?) -> Void) 
        
        loadDataTask.resume()
    }
}
