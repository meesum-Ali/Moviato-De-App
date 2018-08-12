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
//import CryptoSwift

class NetworkManager: NSObject {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let sessionObject: Session = Session.singleton
    // MARK: - Properties
    let defaultManager: Alamofire.SessionManager = {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 180 // seconds
        configuration.allowsCellularAccess = true
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            LIVE_iBANK_URL: .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            ),
            DEV_URL: .disableEvaluation,
            //            BASE_URL: .pinCertificates(
            //                certificates: ServerTrustPolicy.certificates(),
            //                validateCertificateChain: true,
            //                validateHost: true
            //            ), //.disableEvaluation
            //            "\(BASE_URL)\("hblid")": .pinCertificates(
            //                certificates: ServerTrustPolicy.certificates(),
            //                validateCertificateChain: true,
            //                validateHost: true
            //            ), //.disableEvaluation
        ]
        
        //        let serverTrustPolicies: [String: ServerTrustPolicy] = [
        //            //            BASE_URL: .pinCertificates(
        //            //                certificates: ServerTrustPolicy.certificates(),
        //            //                validateCertificateChain: true,
        //            //                validateHost: true
        //            //            ),
        //            BASE_URL: .disableEvaluation,
        //            ]
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    private static var sharedNetworkManager: NetworkManager = {
        let networkManager = NetworkManager(baseURL: URL.init(string: BASE_URL)!)
        
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
    
    // MARK :- Request Method
    fileprivate func printJsonString(_ json: Any) {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print("Json String: \(convertedString!)") // <-- here is ur string
            
        } catch let myJSONError {
            
            print(myJSONError)
            
        }
    }
    
    func sendrequest(body: [String:Any], vc: UIViewController, shouldShowAlert: Bool? = true, completionHandler: @escaping (_ result: CustomResponse?, _ isSuccess: Bool) -> Void) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let headers: HTTPHeaders = [
            "Authorization": (sessionData![SK_SESSION_TOKEN_LOGIN] as? String) ?? "",
            "cookie" : (sessionData![SK_JSESSIONID] as? String) ?? ""
        ]
        
        defaultManager.request("\(BASE_URL)\(SERVER_MODULE_NAME)/mbMainController", method:.post, parameters:body, encoding:JSONEncoding.default , headers: headers).responseJSON {
            response in
            
            var isSuccess = false
            var resp:CustomResponse?
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch response.result {
                
            case .success:
                
                if let json = response.result.value {
                    // print("JSON RESPONSE : \(json)")
                    self.printJsonString(json)
                    resp = getDeSerializeObj(responseData: json)
                    
                    if let newToken = resp?.header?.token {
                        self.sessionObject.updateToken(tkn: newToken)
                        sessionData![SK_SESSION_TOKEN] = newToken
                    }
                    
                    if resp == nil  || resp?.header?.status != "SUCCESS" {
                        
                        var eMsg = kErrorPerformingOperation
                        
                        let errorDescription = resp?.header?.responseDescription
                        let jResp = json as! [String:Any]
                        
                        if (errorDescription != nil && errorDescription != "") {
                            eMsg = errorDescription!
                        }
                        else if(jResp["message"] != nil){
                            eMsg = jResp["message"] as! String
                        }
                        
                        if(resp?.header?.responseCode == "INVALID_PARAMETERS" || jResp["status"] as? Int == 401 || jResp["error"] as? String == "Unauthorized" ) {
                            
                            showAlert(title: Constants.mAlertTitleSessionTimeOut, msg: Constants.mSessionTimedOut, isInfoPopup: true, vc: vc, completionHandler: {
                                self.appDelegate.kPerformLogout(vc: nil)
                            })
                            
                            completionHandler(resp, isSuccess)
                        }
                        else if (resp?.header?.transactionType == klistDebitCards && resp?.header?.responseCode == kFeatureNotAvailable) || !shouldShowAlert!{
                            
                            completionHandler(resp, isSuccess)
                            
                        }
                        else if (resp?.header?.responseCode == "0000" ) && (resp?.header?.transactionType == kEnableSmsAlert || resp?.header?.transactionType == kEnableEstatement){
                            
                            showAlert(title: "", msg: eMsg, isInfoPopup: true, vc: vc, completionHandler: {
                                
                            })
                            completionHandler(resp, isSuccess)
                        }
                            
                        else{
                            
                            showAlert(title: Constants.mAlertTitleError, msg: eMsg, vc: vc, completionHandler: {})
                            completionHandler(resp, isSuccess)
                        }
                        return
                    }
                    isSuccess = true
                    
                    
                    completionHandler(resp, isSuccess)
                    
                    return
                }
                break
                
            case .failure(let error):
                //HTTPERROR RESPONSE HANDLING
                isSuccess = false
                
                if(response.response?.statusCode == 401 ) {
                    
                    showAlert(title: Constants.mAlertTitleSessionTimeOut, msg: Constants.mSessionTimedOut, isInfoPopup: true, vc: vc, completionHandler: {
                        self.appDelegate.kPerformLogout(vc: nil)
                    })
                    
                    completionHandler(resp, isSuccess)
                }
                
                if !shouldShowAlert! {
                    completionHandler(resp, isSuccess)
                    return
                }
                if let err = error as? URLError, err.code == .notConnectedToInternet {
                    //if response.response?.statusCode == -1009 {
                    showAlert(title: Constants.mAlertTitleError, msg:kConnectionError , vc: vc, completionHandler: {
                        isSuccess = false
                        
                    })
                    completionHandler(resp, isSuccess)
                    return
                }
                
                if  response.result.value as? NSDictionary != nil {
                    
                    showAlert(title: Constants.mAlertTitleError, msg: error.localizedDescription, vc: vc, completionHandler: {})
                    completionHandler(resp, isSuccess)
                    return
                    
                }
                else{
                    //error.localizedDescription
                    //"We are unable to process your request. Please try again later."
                    showAlert(title: Constants.mAlertTitleError, msg: kErrorPerformingOperation, vc: vc, completionHandler: {})
                    completionHandler(resp, isSuccess)
                    return
                }
            }
        }
        
    }
    
    //MARK:-  Send Request Method for login
    
    func sendRequestForLogin(endUrl: String, body: [String:Any], vc: UIViewController, contentType : [String: String], shouldShowProgress: Bool? = true, shouldShowAlert: Bool? = true, completionHandler: @escaping (_ jSon: Any, _ result: NSDictionary?, _ isSuccess: Bool, _ error: String?) -> Void){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var encodingType : ParameterEncoding = JSONEncoding.default
        if (contentType == Constants.contentTypeForm){
            encodingType = URLEncoding.queryString
        }
        
        let progV = RequestProgressIndicatiorView(frame: UIScreen.main.bounds)
        let window = UIApplication.shared.keyWindow!
        
        if shouldShowProgress! {
            window.addSubview(progV);
        }
        
        var contentHead = contentType
        contentHead["cookie"] = (sessionData![SK_JSESSIONID] as? String) ?? ""
        
        defaultManager.request("\(BASE_URL)\(endUrl)", method:.post, parameters:body, encoding:encodingType , headers: contentHead).responseJSON {
            response in
            
            var isSuccess = false
            let isError : String? = nil
            var resp:NSDictionary?
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            debugPrint("RESPONSE : \(response)")
            
            switch response.result {
                
            case .success:
                progV.removeFromSuperview()
                if let json = response.result.value {
                    print("JSON RESPONSE : \(json)")
                    
                    self.printJsonString(json)
                    
                    let httpHeaderDict: [String:Any] = response.response?.allHeaderFields as! [String : Any]
                    let authToken = httpHeaderDict["Authorization"]
                    sessionData![SK_SESSION_TOKEN_LOGIN] = authToken
                    
                    let jSessionIDToken = httpHeaderDict["Set-Cookie"]
                    
                    sessionData![SK_JSESSIONID] = jSessionIDToken
                    
                    //                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: response.response?.allHeaderFields as! [String : String], for: (response.request?.url)!)
                    //
                    //                    for cookie in cookies {
                    //                        print(cookie)
                    //                        let name = cookie.name
                    //                        if name == "JSESSIONID" {
                    //                            let value = cookie.value
                    //                            sessionData![SK_JSESSIONID] = value
                    //                            print(value)
                    //                        }
                    //                    }
                    
                    //                    sessionData![SK_JSESSIONID] = response.response.
                    
                    resp = json as? NSDictionary
                    if resp == nil  || resp!["resultcode"] == nil || resp!["resultcode"] as! String != "SUCCESS" {
                        
                        var eMsg = kErrorPerformingOperation
                        if (endUrl == kLogin){
                            eMsg = kLoginErrorString
                        }
                        let errorDescription = resp?.value(forKey: "resultdescription") as? String;
                        
                        if (errorDescription != nil) {
                            eMsg = errorDescription!
                        }
                        
                        if shouldShowAlert! == true {
                            showAlert(title: Constants.mAlertTitleError, msg: eMsg, vc: vc, completionHandler: {})
                        }
                        completionHandler(json,[:], isSuccess, eMsg )
                        
                        return
                    }
                    
                    if resp!["resultcode"] as! String == "SUCCESS" {
                        isSuccess = true
                        SERVER_MODULE_NAME = "hblmb"
                        if let newToken = resp?.value(forKey: "token") as? String {
                            self.sessionObject.updateToken(tkn: newToken)
                            sessionData![SK_SESSION_TOKEN] = newToken
                        }
                        
                        if (progVC?.viewIfLoaded?.window != nil) {
                            progVC!.dismiss(animated: false, completion: {
                                completionHandler(json,(resp)!, isSuccess, isError)
                            })
                        }
                        else{
                            completionHandler(json,(resp)!, isSuccess, isError)
                        }
                    }
                    return
                }
                break
                
            case .failure(let error):
                //HTTPERROR RESPONSE HANDLING
                progV.removeFromSuperview()
                isSuccess = false
                
                var errMsg = ""
                if let err = error as? URLError, err.code == .notConnectedToInternet {
                    errMsg = kConnectionError
                }
                else if  response.result.value as? NSDictionary != nil {
                    errMsg = error.localizedDescription
                }
                else{
                    errMsg = kErrorPerformingOperation
                }
                
                if shouldShowAlert! == true {
                    showAlert(title: Constants.mAlertTitleError, msg: errMsg, vc: vc, completionHandler: {
                        
                    })
                }
                completionHandler("", [:], isSuccess, errMsg )
                return
            }
        }
        
    }
}

