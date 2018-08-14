//
//  networking.swift
//  Konnect App
//
//  Created by Muhammad Talha Ashfaque on 12/7/17.
//  Copyright © 2017 Muhammad Talha Ashfaque. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
/// A small custom wrapper on alamofire to customize according to app needs and all network related stuff is to be done here instead of controllers and other classes.
class NetworkManager: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Properties
    let defaultManager: Alamofire.SessionManager = {
        
        return Alamofire.SessionManager()
        
    }()
    
    private static var sharedNetworkManager: NetworkManager = {
        let networkManager = NetworkManager(baseURL: URL.init(string: "http://api.themoviedb.org/3/search/movie")!)
        
        // Configuration
        // ...
        
        return networkManager
    }()
    
    // MARK: -
    
    let baseURL: URL
    // Initialization
    
    private init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - Accessors
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
    ///simple send request method designed for get requests only so far... its highly modifiable but not done yet :) all errors are handled from here and no need to specifically handle in controllers.
    func sendrequest(body: [String:Any],
                     vc: UIViewController,
                     shouldShowAlert: Bool? = true,
                     completionHandler: @escaping (_ result: CustomResponse?,
        _ isSuccess: Bool) -> Void) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        defaultManager.request(self.baseURL,
                               method: .get,
                               parameters: body,
                               encoding: URLEncoding.queryString,
                               headers: nil).responseJSON { (response) in
                                
                                var isSuccess = false
                                var resp:CustomResponse?
                                
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                
                                switch response.result {
                                    
                                case .success:
                                    
                                    if let json = response.result.value {
                                        self.printJsonString(json)
                                        resp = getDeSerializeObj(responseData: json)
                                        
                                        isSuccess = true
                                        
                                        
                                        completionHandler(resp, isSuccess)
                                        
                                        return
                                    }
                                    break
                                    
                                case .failure(let error):
                                    //HTTPERROR RESPONSE HANDLING
                                    isSuccess = false
                                    
                                    if !shouldShowAlert! {
                                        completionHandler(resp, isSuccess)
                                        return
                                    }
                                    
                                    if let err = error as? URLError, err.code == .notConnectedToInternet {
                                        //if response.response?.statusCode == -1009 {
                                        showAlert(title: "Alert", msg:kConnectionError ,
                                                  vc: vc,
                                                  completionHandler: {
                                                    isSuccess = false
                                                    
                                        })
                                        completionHandler(resp, isSuccess)
                                        return
                                    }
                                    
                                    if  response.result.value as? NSDictionary != nil {
                                        
                                        showAlert(title: "Alert",
                                                  msg: error.localizedDescription,
                                                  vc: vc,
                                                  completionHandler: {})
                                        
                                        completionHandler(resp, isSuccess)
                                        return
                                        
                                    }
                                    else{
                                        //error.localizedDescription
                                        //"We are unable to process your request. Please try again later."
                                        showAlert(title: "Alert",
                                                  msg: kErrorPerformingOperation,
                                                  vc: vc,
                                                  completionHandler: {})
                                        
                                        completionHandler(resp, isSuccess)
                                        return
                                    }
                                }
        }
        
    }
    
    // MARK :- Method for pretty printing json.
    fileprivate func printJsonString(_ json: Any) {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print("Json String: \(convertedString!)") // <-- here is ur string
            
        } catch let myJSONError {
            
            print(myJSONError)
            
        }
    }
}

